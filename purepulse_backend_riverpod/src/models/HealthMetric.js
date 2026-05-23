const pool = require('../config/db');

class HealthMetric {
  static async findLatestByUserId(userId) {
    const result = await pool.query(
      `SELECT * FROM health_metrics 
       WHERE user_id = $1 
       ORDER BY date DESC 
       LIMIT 1`,
      [userId]
    );
    return result.rows[0];
  }

  static async findById(id, userId) {
    const result = await pool.query(
      'SELECT * FROM health_metrics WHERE id = $1 AND user_id = $2',
      [id, userId]
    );
    return result.rows[0];
  }

  static async findHistory(userId, limit = 50, offset = 0) {
    const result = await pool.query(
      `SELECT * FROM health_metrics 
       WHERE user_id = $1 
       ORDER BY date DESC 
       LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );
    return result.rows;
  }

  static async create(userId, data) {
    const result = await pool.query(
      `INSERT INTO health_metrics (user_id, weight, height, bmi, resting_heart_rate, blood_pressure_systolic, blood_pressure_diastolic, blood_sugar, date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [
        userId,
        data.weight,
        data.height,
        data.bmi,
        data.restingHeartRate,
        data.bloodPressureSystolic,
        data.bloodPressureDiastolic,
        data.bloodSugar,
        data.measurementDate || new Date()
      ]
    );
    return result.rows[0];
  }

  static async update(id, userId, data) {
    const updates = [];
    const values = [];
    let paramCount = 1;

    if (data.weight !== undefined) {
      updates.push(`weight = $${paramCount++}`);
      values.push(data.weight);
    }
    if (data.height !== undefined) {
      updates.push(`height = $${paramCount++}`);
      values.push(data.height);
    }
    if (data.restingHeartRate !== undefined) {
      updates.push(`resting_heart_rate = $${paramCount++}`);
      values.push(data.restingHeartRate);
    }
    if (data.bloodPressureSystolic !== undefined) {
      updates.push(`blood_pressure_systolic = $${paramCount++}`);
      values.push(data.bloodPressureSystolic);
    }
    if (data.bloodPressureDiastolic !== undefined) {
      updates.push(`blood_pressure_diastolic = $${paramCount++}`);
      values.push(data.bloodPressureDiastolic);
    }
    if (data.bloodSugar !== undefined) {
      updates.push(`blood_sugar = $${paramCount++}`);
      values.push(data.bloodSugar);
    }
    if (data.measurementDate !== undefined) {
      updates.push(`date = $${paramCount++}`);
      values.push(data.measurementDate);
    }

    if (data.weight !== undefined || data.height !== undefined) {
      const current = await HealthMetric.findById(id, userId);
      const weight = data.weight ?? current.weight;
      const height = data.height ?? current.height;
      if (weight && height) {
        updates.push(`bmi = $${paramCount++}`);
        values.push(weight / Math.pow(height / 100, 2));
      }
    }

    if (updates.length === 0) {
      return HealthMetric.findById(id, userId);
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id, userId);

    const result = await pool.query(
      `UPDATE health_metrics SET ${updates.join(', ')} WHERE id = $${paramCount++} AND user_id = $${paramCount} RETURNING *`,
      values
    );
    return result.rows[0];
  }

  static async delete(id, userId) {
    const result = await pool.query(
      'DELETE FROM health_metrics WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId]
    );
    return result.rows[0];
  }

  static async count(userId) {
    const result = await pool.query(
      'SELECT COUNT(*) as total FROM health_metrics WHERE user_id = $1',
      [userId]
    );
    return parseInt(result.rows[0].total, 10);
  }
}

module.exports = HealthMetric;
