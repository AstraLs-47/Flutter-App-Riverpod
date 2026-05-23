const authService = require('../services/authService');

class AuthController {
  async signup(req, res, next) {
    try {
      const { email, password, firstName, lastName } = req.body;
      if (!email || !password || !firstName || !lastName) {
        return res.status(400).json({ error: 'All fields are required' });
      }
      if (password.length < 6) {
        return res.status(400).json({ error: 'Password must be at least 6 characters' });
      }
      const result = await authService.signup(email, password, firstName, lastName);
      res.status(201).json(result);
    } catch (error) {
      next(error);
    }
  }

  async signin(req, res, next) {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
      }
      const result = await authService.signin(email, password);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }

  async signout(req, res, next) {
    try {
      res.json({ message: 'Signed out successfully' });
    } catch (error) {
      next(error);
    }
  }

  async getCurrentUser(req, res, next) {
    try {
      const user = await authService.getCurrentUser(req.user.id);
      res.json(user);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AuthController();