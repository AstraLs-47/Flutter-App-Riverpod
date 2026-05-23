const pool = require('../config/db');

class ProgressEntry {
  static async findByUserId(userId, limit = 50, offset = 0) {
    const result = await pool.query(
      `SELECT p.*, COALESCE(e.name, p.exercise_name) as exercise_name, e.image_url as exercise_image
       FROM progress_entries p
       LEFT JOIN exercises e ON p.exercise_id = e.id
       WHERE p.user_id = $1
       ORDER BY p.entry_date DESC, p.created_at DESC
       LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );
    return result.rows;
  }

  static async findById(id, userId) {
    const result = await pool.query(
      `SELECT p.*, COALESCE(e.name, p.exercise_name) as exercise_name, e.image_url as exercise_image
       FROM progress_entries p
       LEFT JOIN exercises e ON p.exercise_id = e.id
       WHERE p.id = $1 AND p.user_id = $2`,
      [id, userId]
    );
    return result.rows[0];
  }

  static async create(userId, data) {
    const result = await pool.query(
      `INSERT INTO progress_entries (user_id, exercise_id, exercise_name, weight, reps, sets, duration_minutes, notes, intensity, achievement, mood, entry_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
       RETURNING *`,
      [
        userId,
        data.exerciseId,
        data.exerciseName,
        data.weight,
        data.reps,
        data.sets,
        data.durationMinutes,
        data.notes,
        data.intensity,
        data.achievement,
        data.mood,
        data.entryDate || new Date()
      ]
    );
    return result.rows[0];
  }

  static async update(id, userId, data) {
    const updates = [];
    const values = [];
    let paramCount = 1;

    const fields = {
      exerciseId: 'exercise_id',
      exerciseName: 'exercise_name',
      weight: 'weight',
      reps: 'reps',
      sets: 'sets',
      durationMinutes: 'duration_minutes',
      notes: 'notes',
      intensity: 'intensity',
      achievement: 'achievement',
      mood: 'mood',
      entryDate: 'entry_date'
    };

    for (const [key, dbField] of Object.entries(fields)) {
      if (data[key] !== undefined) {
        updates.push(`${dbField} = $${paramCount++}`);
        values.push(data[key]);
      }
    }

    if (updates.length === 0) {
      return ProgressEntry.findById(id, userId);
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id, userId);

    const result = await pool.query(
      `UPDATE progress_entries SET ${updates.join(', ')} WHERE id = $${paramCount++} AND user_id = $${paramCount} RETURNING *`,
      values
    );
    return result.rows[0];
  }

  static async delete(id, userId) {
    const result = await pool.query(
      'DELETE FROM progress_entries WHERE id = $1 AND user_id = $2 RETURNING id',
      [id, userId]
    );
    return result.rows[0];
  }

  static async getStats(userId) {
    const result = await pool.query(
      `SELECT 
        COUNT(*) as total_entries,
        SUM(duration_minutes) as total_minutes,
        SUM(weight * reps * sets) as total_volume,
        MAX(entry_date) as last_entry_date,
        COUNT(DISTINCT exercise_id) as exercises_used
       FROM progress_entries 
       WHERE user_id = $1`,
      [userId]
    );
    return result.rows[0];
  }

  static async getTodaySummary(userId) {
    const result = await pool.query(
      `SELECT 
        COUNT(*) as workouts_today,
        COALESCE(SUM(p.duration_minutes * COALESCE(e.calories_per_minute, 0)), 0) as calories_today
       FROM progress_entries p
       LEFT JOIN exercises e ON p.exercise_id = e.id
       WHERE p.user_id = $1 AND p.entry_date = CURRENT_DATE`,
      [userId]
    );
    return result.rows[0];
  }

  static async count(userId) {
    const result = await pool.query(
      'SELECT COUNT(*) as total FROM progress_entries WHERE user_id = $1',
      [userId]
    );
    return parseInt(result.rows[0].total, 10);
  }
}

module.exports = ProgressEntry;
