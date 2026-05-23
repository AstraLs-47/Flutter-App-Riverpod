const categoryService = require('../services/categoryService');

class CategoryController {
  async list(req, res, next) {
    try {
      const { type } = req.query;
      const categories = await categoryService.list(type);
      res.json(categories);
    } catch (error) {
      next(error);
    }
  }

  async create(req, res, next) {
    try {
      const { name, type } = req.body;
      if (!name) {
        return res.status(400).json({ error: 'Category name is required' });
      }
      const category = await categoryService.create({ name, type });
      res.status(201).json(category);
    } catch (error) {
      next(error);
    }
  }

  async delete(req, res, next) {
    try {
      const id = parseInt(req.params.id, 10);
      if (Number.isNaN(id)) {
        return res.status(400).json({ error: 'Invalid category id' });
      }
      const result = await categoryService.delete(id);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new CategoryController();