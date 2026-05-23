const pool = require('../config/db');

class Category {
  static async findAll(type = null) {
    let query = 'SELECT * FROM categories';
    const values = [];
    
    if (type) {
      query += ' WHERE type = $1';
      values.push(type);
    }
    
    query += ' ORDER BY name';
    const result = await pool.query(query, values);
    return result.rows;
  }

  static async findById(id) {
    const result = await pool.query('SELECT * FROM categories WHERE id = $1', [id]);
    return result.rows[0];
  }

  static async findByName(name) {
    const result = await pool.query('SELECT * FROM categories WHERE LOWER(name) = LOWER($1) LIMIT 1', [name]);
    return result.rows[0];
  }

  static async create(data) {
    const type = data.type || 'general';
    const result = await pool.query(
      'INSERT INTO categories (name, type) VALUES ($1, $2) RETURNING *',
      [data.name, type]
    );
    return result.rows[0];
  }

  static async delete(id) {
    const result = await pool.query('DELETE FROM categories WHERE id = $1 RETURNING id', [id]);
    return result.rows[0];
  }
}

module.exports = Category;
