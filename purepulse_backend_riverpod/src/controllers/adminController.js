const adminService = require('../services/adminService');

class AdminController {
  async getDashboard(req, res, next) {
    try {
      const summary = await adminService.getDashboardSummary();
      res.json(summary);
    } catch (error) {
      next(error);
    }
  }

  async getUserStats(req, res, next) {
    try {
      const stats = await adminService.getUserStats();
      res.json(stats);
    } catch (error) {
      next(error);
    }
  }

  async getExerciseStats(req, res, next) {
    try {
      const stats = await adminService.getExerciseStats();
      res.json(stats);
    } catch (error) {
      next(error);
    }
  }

  async getProgressStats(req, res, next) {
    try {
      const stats = await adminService.getProgressStats();
      res.json(stats);
    } catch (error) {
      next(error);
    }
  }

  async getHealthStats(req, res, next) {
    try {
      const stats = await adminService.getHealthStats();
      res.json(stats);
    } catch (error) {
      next(error);
    }
  }

  async getProductStats(req, res, next) {
    try {
      const stats = await adminService.getProductStats();
      res.json(stats);
    } catch (error) {
      next(error);
    }
  }

  async getActivityLogs(req, res, next) {
    try {
      const { page = 1, limit = 100 } = req.query;
      const result = await adminService.getActivityLogs(parseInt(page), parseInt(limit));
      res.json(result.logs);
    } catch (error) {
      next(error);
    }
  }

  async getActivityStats(req, res, next) {
    try {
      const stats = await adminService.getActivityStats();
      res.json(stats);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AdminController();