const userService = require('../services/userService');

class UserController {
  async getProfile(req, res, next) {
    try {
      const user = await userService.getProfile(req.user.id);
      res.json(user);
    } catch (error) {
      next(error);
    }
  }

  async getDashboard(req, res, next) {
    try {
      const dashboard = await userService.getDashboard(req.user.id);
      res.json(dashboard);
    } catch (error) {
      next(error);
    }
  }

  async updateProfile(req, res, next) {
    try {
      const { firstName, lastName, gender, goal, activityLevel, dateOfBirth, height, currentWeight, goalWeight } = req.body;
      const updatedUser = await userService.updateProfile(req.user.id, {
        firstName, lastName, gender, goal, activityLevel, dateOfBirth, height, currentWeight, goalWeight
      });
      res.json(updatedUser);
    } catch (error) {
      next(error);
    }
  }

  async onboard(req, res, next) {
    try {
      const { goal, activityLevel, dateOfBirth, currentWeight, goalWeight, height, gender } = req.body;
      if (!goal || !dateOfBirth || !currentWeight || !goalWeight || !height) {
        return res.status(400).json({ error: 'All survey fields are required' });
      }
      const updatedUser = await userService.updateProfile(req.user.id, {
        goal, activityLevel, dateOfBirth, height, currentWeight, goalWeight, gender
      });
      res.json(updatedUser);
    } catch (error) {
      next(error);
    }
  }

  async deleteAccount(req, res, next) {
    try {
      const result = await userService.deleteAccount(req.user.id);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new UserController();