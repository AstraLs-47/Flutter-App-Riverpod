const exerciseService = require('../services/exerciseService');

class ExerciseController {
  async list(req, res, next) {
    try {
      const { categoryId, difficulty, page = 1, limit = 50 } = req.query;
      const result = await exerciseService.list(
        categoryId ? parseInt(categoryId) : null,
        difficulty,
        parseInt(page),
        parseInt(limit)
      );
      res.json(result.exercises);
    } catch (error) {
      next(error);
    }
  }

  async getById(req, res, next) {
    try {
      const exercise = await exerciseService.getById(parseInt(req.params.id));
      res.json(exercise);
    } catch (error) {
      next(error);
    }
  }

  async create(req, res, next) {
    try {
      const {
        title,
        name,
        description,
        category,
        categoryId,
        category_id,
        warmup,
        mainWorkout,
        rest,
        duration,
        difficulty,
        caloriesPerMinute,
        imageUrl,
        image
      } = req.body;
      if (!name && !title) {
        return res.status(400).json({ error: 'Exercise name is required' });
      }
      const resolvedCategoryId = categoryId || category_id || category;
      const exercise = await exerciseService.create({
        name: title || name,
        description,
        categoryId: resolvedCategoryId,
        difficulty,
        warmup,
        mainWorkout,
        rest,
        duration,
        caloriesPerMinute,
        imageUrl: imageUrl || image,
        createdBy: req.user.id
      });
      res.status(201).json(exercise);
    } catch (error) {
      next(error);
    }
  }

  async update(req, res, next) {
    try {
      const {
        title,
        name,
        description,
        category,
        categoryId,
        category_id,
        warmup,
        mainWorkout,
        rest,
        duration,
        difficulty,
        caloriesPerMinute,
        imageUrl,
        image
      } = req.body;
      const resolvedCategoryId = categoryId || category_id || category;
      const exercise = await exerciseService.update(parseInt(req.params.id), {
        name: title || name,
        description,
        categoryId: resolvedCategoryId,
        difficulty,
        warmup,
        mainWorkout,
        rest,
        duration,
        caloriesPerMinute,
        imageUrl: imageUrl || image
      });
      res.json(exercise);
    } catch (error) {
      next(error);
    }
  }

  async delete(req, res, next) {
    try {
      const result = await exerciseService.delete(parseInt(req.params.id));
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new ExerciseController();