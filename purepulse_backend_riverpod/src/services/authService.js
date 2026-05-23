const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

class AuthService {
  async signup(email, password, firstName, lastName) {
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      const error = new Error('Email already registered');
      error.statusCode = 409;
      throw error;
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const user = await User.create({ email, passwordHash, firstName, lastName });
    const token = this.generateToken(user);

    return {
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName || user.first_name || firstName,
        lastName: user.lastName || user.last_name || lastName,
        role: user.role
      },
      token
    };
  }

  async signin(email, password) {
    const user = await User.findByEmail(email);
    if (!user) {
      const error = new Error('Invalid email or password');
      error.statusCode = 401;
      throw error;
    }

    const storedHash = user.password_hash || user.passwordHash;
    const isValidPassword = await bcrypt.compare(password, storedHash);
    if (!isValidPassword) {
      const error = new Error('Invalid email or password');
      error.statusCode = 401;
      throw error;
    }

    const token = this.generateToken(user);
    return {
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName || user.first_name,
        lastName: user.lastName || user.last_name,
        role: user.role
      },
      token
    };
  }

  async getCurrentUser(userId) {
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
      dateOfBirth: user.dateOfBirth || user.date_of_birth,
      height: user.height,
      currentWeight: user.currentWeight || user.current_weight,
      goalWeight: user.goalWeight || user.goal_weight,
      createdAt: user.createdAt || user.created_at
    };
  }

  generateToken(user) {
    return jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
  }
}

module.exports = new AuthService();