const pool = require('../config/db');

class Announcement {
  static async findAll(limit = 20, offset = 0) {
    const result = await pool.query(
      `SELECT * FROM announcements ORDER BY created_at DESC LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    return result.rows;
  }

  static async findById(id) {
    const result = await pool.query('SELECT * FROM announcements WHERE id = $1', [id]);
    return result.rows[0];
  }

  static async count() {
    const result = await pool.query('SELECT COUNT(*) as total FROM announcements');
    return parseInt(result.rows[0].total, 10);
  }

  static async create(data) {
    const { title, description, date, createdBy } = data;
    const result = await pool.query(
      `INSERT INTO announcements (title, description, date, created_by)
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [title, description, date, createdBy]
    );
    return result.rows[0];
  }

  static async update(id, data) {
    const { title, description, date } = data;
    const result = await pool.query(
      `UPDATE announcements SET title = $1, description = $2, date = $3, updated_at = CURRENT_TIMESTAMP
       WHERE id = $4 RETURNING *`,
      [title, description, date, id]
    );
    return result.rows[0];
  }

  static async delete(id) {
    const result = await pool.query('DELETE FROM announcements WHERE id = $1 RETURNING id', [id]);
    return result.rows[0];
  }
}

module.exports = Announcement;
