const pool = require('../config/db');

class Product {
  static async findAll(limit = 50, offset = 0) {
    const result = await pool.query(
      `SELECT * FROM products WHERE is_active = true ORDER BY created_at DESC LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    return result.rows;
  }

  static async findById(id) {
    const result = await pool.query('SELECT * FROM products WHERE id = $1', [id]);
    return result.rows[0];
  }

  static async count() {
    const result = await pool.query('SELECT COUNT(*) as total FROM products WHERE is_active = true');
    return parseInt(result.rows[0].total, 10);
  }

  static async create(data) {
    const { name, description, category, imageUrl, image, createdBy } = data;
    const result = await pool.query(
      `INSERT INTO products (name, description, category, image_url, created_by)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [name, description, category, imageUrl || image, createdBy]
    );
    return result.rows[0];
  }

  static async update(id, data) {
    const { name, description, category, imageUrl, image, isActive } = data;
    const result = await pool.query(
      `UPDATE products SET name = $1, description = $2, category = $3,
       image_url = $4, is_active = $5, updated_at = CURRENT_TIMESTAMP
       WHERE id = $6 RETURNING *`,
      [name, description, category, imageUrl || image, isActive, id]
    );
    return result.rows[0];
  }

  static async delete(id) {
    await pool.query('DELETE FROM products WHERE id = $1', [id]);
  }
}

module.exports = Product;
