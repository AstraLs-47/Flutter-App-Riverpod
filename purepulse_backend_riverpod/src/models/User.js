const pool = require('../config/db');

class User {
  constructor(row) {
    this.id = row.id;
    this.email = row.email;
    this.passwordHash = row.password_hash;
    this.firstName = row.first_name;
    this.lastName = row.last_name;
    this.role = row.role;
    this.createdAt = row.created_at;
    this.updatedAt = row.updated_at;
    this.age = row.age;
    this.gender = row.gender;
    this.goal = row.goal;
    this.activityLevel = row.activity_level;
    this.dateOfBirth = row.date_of_birth;
    this.height = row.height;
    this.currentWeight = row.current_weight;
    this.goalWeight = row.goal_weight;
  }

  static mapRow(row) {
    return row ? new User(row) : null;
  }

  static async findByEmail(email) {
    const result = await pool.query(
      `SELECT u.id, u.email, u.password_hash, u.first_name, u.last_name, u.role, u.created_at, u.updated_at,
              p.age, p.gender, p.goal, p.activity_level, p.date_of_birth, p.height, p.current_weight, p.goal_weight
       FROM users u
       LEFT JOIN user_profiles p ON u.id = p.user_id
       WHERE u.email = $1`,
      [email]
    );
    return User.mapRow(result.rows[0]);
  }

  static async findById(id) {
    const result = await pool.query(
      `SELECT u.id, u.email, u.first_name, u.last_name, u.role, u.created_at, u.updated_at,
              p.age, p.gender, p.goal, p.activity_level, p.date_of_birth, p.height, p.current_weight, p.goal_weight
       FROM users u
       LEFT JOIN user_profiles p ON u.id = p.user_id
       WHERE u.id = $1`,
      [id]
    );
    return User.mapRow(result.rows[0]);
  }

  static async create({ email, passwordHash, firstName, lastName, role = 'user' }) {
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, first_name, last_name, role)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, email, first_name, last_name, role, created_at, updated_at`,
      [email, passwordHash, firstName, lastName, role]
    );
    return User.mapRow(result.rows[0]);
  }

  static async update(id, fields) {
    const updates = [];
    const values = [];
    let paramCount = 1;

    if (fields.firstName !== undefined) {
      updates.push(`first_name = $${paramCount++}`);
      values.push(fields.firstName);
    }
    if (fields.lastName !== undefined) {
      updates.push(`last_name = $${paramCount++}`);
      values.push(fields.lastName);
    }

    if (updates.length === 0) {
      return User.findById(id);
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id);

    const result = await pool.query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramCount}
       RETURNING id, email, first_name, last_name, role, created_at, updated_at`,
      values
    );
    return User.mapRow(result.rows[0]);
  }

  static async updatePassword(userId, passwordHash) {
    const result = await pool.query(
      'UPDATE users SET password_hash = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING id',
      [passwordHash, userId]
    );
    return result.rows[0];
  }

  static async delete(id) {
    const result = await pool.query(
      'DELETE FROM users WHERE id = $1 RETURNING id',
      [id]
    );
    return result.rows[0];
  }
}

module.exports = User;
