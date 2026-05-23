const announcementService = require('../services/announcementService');

class AnnouncementController {
  async list(req, res, next) {
    try {
      const { page = 1, limit = 20 } = req.query;
      const result = await announcementService.list(parseInt(page), parseInt(limit));
      res.json(result.announcements);
    } catch (error) {
      next(error);
    }
  }

  async getById(req, res, next) {
    try {
      const announcement = await announcementService.getById(parseInt(req.params.id));
      res.json(announcement);
    } catch (error) {
      next(error);
    }
  }

  async create(req, res, next) {
    try {
      const { title, description, date } = req.body;
      if (!title || !description) {
        return res.status(400).json({ error: 'Title and description are required' });
      }
      const announcement = await announcementService.create({ title, description, date, created_by: req.user.id });
      res.status(201).json(announcement);
    } catch (error) {
      next(error);
    }
  }

  async update(req, res, next) {
    try {
      const { title, description, date } = req.body;
      const announcement = await announcementService.update(parseInt(req.params.id), {
        title, description, date
      });
      res.json(announcement);
    } catch (error) {
      next(error);
    }
  }

  async delete(req, res, next) {
    try {
      const result = await announcementService.delete(parseInt(req.params.id));
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AnnouncementController();