const pool = require('../config/db');
const Category = require('./Category');

class Exercise {
  static async findAll(categoryId, difficulty, limit = 50, offset = 0) {
    let query = `
      SELECT e.*, c.name as category_name 
      FROM exercises e
      LEFT JOIN categories c ON e.category_id = c.id
      WHERE 1=1
    `;
    const values = [];
    let paramCount = 1;

    if (categoryId) {
      query += ` AND e.category_id = $${paramCount++}`;
      values.push(categoryId);
    }
    if (difficulty) {
      query += ` AND e.difficulty = $${paramCount++}`;
      values.push(difficulty);
    }

    query += ` ORDER BY e.created_at DESC LIMIT $${paramCount++} OFFSET $${paramCount++}`;
    values.push(limit, offset);

    const result = await pool.query(query, values);
    return result.rows;
  }

  static async findById(id) {
    const result = await pool.query(
      `SELECT e.*, c.name as category_name 
       FROM exercises e
       LEFT JOIN categories c ON e.category_id = c.id
       WHERE e.id = $1`,
      [id]
    );
    return result.rows[0];
  }

  static async create(data) {
    // Resolve categoryId if a category name or snake_case key was provided
    let categoryId = null;
    const rawCategoryId = data.categoryId ?? data.category_id ?? data.category;
    if (rawCategoryId) {
      categoryId = parseInt(rawCategoryId, 10);
      if (Number.isNaN(categoryId)) categoryId = null;
    }

    if (!categoryId && data.category) {
      const existing = await Category.findByName(data.category);
      if (existing) {
        categoryId = existing.id;
      } else {
        const created = await Category.create({ name: data.category, type: 'exercise' });
        categoryId = created.id;
      }
    }

    const result = await pool.query(
      `INSERT INTO exercises (name, description, image_url, category_id, difficulty, warmup, main_workout, rest, duration, calories_per_minute, phases, created_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
       RETURNING *`,
      [
        data.name,
        data.description,
        data.imageUrl || data.image,
        categoryId,
        data.difficulty,
        data.warmup,
        data.mainWorkout,
        data.rest,
        data.duration,
        data.caloriesPerMinute,
        data.phases,
        data.createdBy
      ]
    );
    return result.rows[0];
  }

  static async update(id, data) {
    const updates = [];
    const values = [];
    let paramCount = 1;

    const fields = {
      name: 'name',
      description: 'description',
      imageUrl: 'image_url',
      categoryId: 'category_id',
      difficulty: 'difficulty',
      warmup: 'warmup',
      mainWorkout: 'main_workout',
      rest: 'rest',
      duration: 'duration',
      caloriesPerMinute: 'calories_per_minute',
      phases: 'phases'
    };

    for (const [key, dbField] of Object.entries(fields)) {
      if (data[key] !== undefined) {
        updates.push(`${dbField} = $${paramCount++}`);
        values.push(data[key]);
      }
    }

    if (updates.length === 0) {
      return Exercise.findById(id);
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id);

    const result = await pool.query(
      `UPDATE exercises SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      values
    );
    return result.rows[0];
  }

  static async delete(id) {
    const result = await pool.query('DELETE FROM exercises WHERE id = $1 RETURNING id', [id]);
    return result.rows[0];
  }

  static async count(categoryId, difficulty) {
    let query = 'SELECT COUNT(*) as total FROM exercises WHERE 1=1';
    const values = [];
    let paramCount = 1;

    if (categoryId) {
      query += ` AND category_id = $${paramCount++}`;
      values.push(categoryId);
    }
    if (difficulty) {
      query += ` AND difficulty = $${paramCount++}`;
      values.push(difficulty);
    }

    const result = await pool.query(query, values);
    return parseInt(result.rows[0].total, 10);
  }
}

module.exports = Exercise;
