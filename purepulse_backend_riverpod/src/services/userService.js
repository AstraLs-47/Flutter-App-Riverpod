const User = require('../models/User');
const UserProfile = require('../models/UserProfile');
const ProgressEntry = require('../models/ProgressEntry');
const HealthMetric = require('../models/HealthMetric');

class UserService {
  async getProfile(userId) {
    const user = await User.findById(userId);
    if (!user) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    return {
      id: user.id,
      email: user.email,
      firstName: user.firstName || user.first_name,
      lastName: user.lastName || user.last_name,
      role: user.role,
      age: user.age,
      gender: user.gender,
      goal: user.goal,
      activityLevel: user.activityLevel || user.activity_level,
      dateOfBirth: user.dateOfBirth || user.date_of_birth,
      height: user.height,
      currentWeight: user.currentWeight || user.current_weight,
      goalWeight: user.goalWeight || user.goal_weight,
      createdAt: user.createdAt || user.created_at
    };
  }

  async getDashboard(userId) {
    const [todaySummary, latestHealth] = await Promise.all([
      ProgressEntry.getTodaySummary(userId),
      HealthMetric.findLatestByUserId(userId)
    ]);

    const workoutsToday = parseInt(todaySummary.workouts_today, 10) || 0;
    const caloriesToday = parseFloat(todaySummary.calories_today) || 0;
    const dailyGoalPercent = Math.min(100, workoutsToday * 25);

    const healthSnapshot = latestHealth ? {
      weight: latestHealth.weight || 0,
      bloodPressureSystolic: latestHealth.blood_pressure_systolic || 0,
      bloodPressureDiastolic: latestHealth.blood_pressure_diastolic || 0,
      bloodSugar: latestHealth.blood_sugar || 0,
      restingHeartRate: latestHealth.resting_heart_rate || 0,
      measurementDate: latestHealth.date
    } : {
      weight: 0,
      bloodPressureSystolic: 0,
      bloodPressureDiastolic: 0,
      bloodSugar: 0,
      restingHeartRate: 0,
      measurementDate: null
    };

    return {
      workoutsToday,
      dailyGoalPercent,
      caloriesToday,
      activitiesToday: workoutsToday,
      healthSnapshot
    };
  }

  normalizeDate(dateOfBirth) {
    if (!dateOfBirth) return undefined;

    if (dateOfBirth instanceof Date) {
      if (Number.isNaN(dateOfBirth.getTime())) return undefined;
      return dateOfBirth.toISOString().split('T')[0];
    }

    const input = dateOfBirth.toString().trim();
    const mdyMatch = input.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
    let dob;

    if (mdyMatch) {
      const month = parseInt(mdyMatch[1], 10);
      const day = parseInt(mdyMatch[2], 10);
      const year = parseInt(mdyMatch[3], 10);
      dob = new Date(year, month - 1, day);
      if (dob.getFullYear() !== year || dob.getMonth() !== month - 1 || dob.getDate() !== day) {
        return undefined;
      }
    } else {
      dob = new Date(input);
    }

    if (Number.isNaN(dob.getTime())) return undefined;
    return dob.toISOString().split('T')[0];
  }

  computeAge(dateOfBirth) {
    const normalizedDate = this.normalizeDate(dateOfBirth);
    if (!normalizedDate) return undefined;

    const dob = new Date(normalizedDate);
    const today = new Date();
    let age = today.getFullYear() - dob.getFullYear();
    const monthDiff = today.getMonth() - dob.getMonth();
    const dayDiff = today.getDate() - dob.getDate();
    if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
      age -= 1;
    }

    return Number.isFinite(age) && age >= 0 ? age : undefined;
  }

  parseDecimal(value) {
    if (value === undefined || value === null) return undefined;
    if (typeof value === 'number') {
      return Number.isFinite(value) ? value : undefined;
    }

    const parsed = parseFloat(value.toString().replace(',', '.'));
    return Number.isFinite(parsed) ? parsed : undefined;
  }

  async updateProfile(userId, data) {
    const { firstName, lastName, gender, goal, activityLevel, dateOfBirth, height, currentWeight, goalWeight } = data;
    const age = dateOfBirth ? this.computeAge(dateOfBirth) : undefined;
    const userUpdates = { firstName, lastName };
    const profileUpdates = {
      age,
      gender,
      goal: goal ? this.normalizeGoal(goal) : undefined,
      activityLevel: activityLevel ? this.normalizeActivityLevel(activityLevel) : undefined,
      dateOfBirth: dateOfBirth ? this.normalizeDate(dateOfBirth) : undefined,
      height: this.parseDecimal(height),
      currentWeight: this.parseDecimal(currentWeight),
      goalWeight: this.parseDecimal(goalWeight),
    };

    await User.update(userId, userUpdates);
    if (Object.values(profileUpdates).some(v => v !== undefined)) {
      await UserProfile.upsert({ userId, ...profileUpdates });
    }

    return this.getProfile(userId);
  }

  async deleteAccount(userId) {
    const existingUser = await User.findById(userId);
    if (!existingUser) {
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }

    await User.delete(userId);
    return { message: 'Account deleted successfully' };
  }

  normalizeGoal(goal) {
    if (!goal) return undefined;
    return goal.toString().trim().toLowerCase();
  }

  normalizeActivityLevel(activityLevel) {
    if (!activityLevel) return undefined;
    const normalized = activityLevel.toString().trim().toLowerCase();
    switch (normalized) {
      case 'active':
        return 'Active';
      case 'very active':
        return 'Very Active';
      case 'lightly active':
        return 'Lightly Active';
      case 'not active':
        return 'Not active';
      default:
        return undefined;
    }
  }
}

module.exports = new UserService();