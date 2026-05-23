const pool = require('../config/db');

class UserProfile {
  static async upsert({ userId, age, gender, goal, activityLevel, dateOfBirth, height, currentWeight, goalWeight }) {
    const result = await pool.query(
      `INSERT INTO user_profiles (user_id, age, gender, goal, activity_level, date_of_birth, height, current_weight, goal_weight)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       ON CONFLICT (user_id) DO UPDATE SET
         age = EXCLUDED.age,
         gender = EXCLUDED.gender,
         goal = EXCLUDED.goal,
         activity_level = EXCLUDED.activity_level,
         date_of_birth = EXCLUDED.date_of_birth,
         height = EXCLUDED.height,
         current_weight = EXCLUDED.current_weight,
         goal_weight = EXCLUDED.goal_weight,
         updated_at = CURRENT_TIMESTAMP
       RETURNING *`,
      [userId, age, gender, goal, activityLevel, dateOfBirth, height, currentWeight, goalWeight]
    );
    return result.rows[0];
  }
}

module.exports = UserProfile;
