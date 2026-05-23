const HealthMetric = require('../models/HealthMetric');

class HealthService {
  calculateBMI(weight, height) {
    if (!weight || !height) return null;
    const heightInMeters = height / 100;
    const bmi = weight / Math.pow(heightInMeters, 2);
    return Math.round(bmi * 100) / 100;
  }

  getBMICategory(bmi) {
    if (!bmi) return null;
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'normal';
    if (bmi < 30) return 'overweight';
    return 'obese';
  }

  async getLatestMetrics(userId) {
    const metrics = await HealthMetric.findLatestByUserId(userId);
    if (!metrics) return null;
    return this.formatMetrics(metrics);
  }

  async getById(id, userId) {
    const metrics = await HealthMetric.findById(id, userId);
    if (!metrics) {
      const error = new Error('Health entry not found');
      error.statusCode = 404;
      throw error;
    }
    return this.formatMetrics(metrics);
  }

  async listHistory(userId, page = 1, limit = 50) {
    const offset = (page - 1) * limit;
    const entries = await HealthMetric.findHistory(userId, limit, offset);
    const total = await HealthMetric.count(userId);

    return {
      entries: entries.map(e => this.formatMetrics(e)),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) }
    };
  }

  async addEntry(userId, data) {
    let bmi = null;
    if (data.weight && data.height) {
      bmi = this.calculateBMI(data.weight, data.height);
    }
    const entryData = { ...data, bmi };
    const entry = await HealthMetric.create(userId, entryData);
    return this.formatMetrics(entry);
  }

  async updateMetrics(id, userId, data) {
    const existing = await HealthMetric.findById(id, userId);
    if (!existing) {
      const error = new Error('Health entry not found');
      error.statusCode = 404;
      throw error;
    }
    const entry = await HealthMetric.update(id, userId, data);
    return this.formatMetrics(entry);
  }

  async deleteEntry(id, userId) {
    const existing = await HealthMetric.findById(id, userId);
    if (!existing) {
      const error = new Error('Health entry not found');
      error.statusCode = 404;
      throw error;
    }
    await HealthMetric.delete(id, userId);
    return { message: 'Health entry deleted successfully' };
  }

  formatMetrics(metrics) {
    const bmi = metrics.bmi ? parseFloat(metrics.bmi) : null;
    return {
      id: metrics.id,
      userId: metrics.user_id,
      weight: metrics.weight,
      height: metrics.height,
      bmi: bmi,
      bmiCategory: this.getBMICategory(bmi),
      restingHeartRate: metrics.resting_heart_rate,
      heartRate: metrics.resting_heart_rate,
      bloodPressureSystolic: metrics.blood_pressure_systolic,
      bloodPressureDiastolic: metrics.blood_pressure_diastolic,
      bloodSugar: metrics.blood_sugar,
      measurementDate: metrics.date,
      createdAt: metrics.created_at,
      updatedAt: metrics.updated_at
    };
  }
}

module.exports = new HealthService();