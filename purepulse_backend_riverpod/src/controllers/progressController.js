const progressService = require('../services/progressService');

function parseNullableInt(value) {
  if (value === undefined || value === null || value === '') return null;
  const parsed = parseInt(value, 10);
  return Number.isNaN(parsed) ? null : parsed;
}

function parseNullableFloat(value) {
  if (value === undefined || value === null || value === '') return null;
  const parsed = parseFloat(value);
  return Number.isNaN(parsed) ? null : parsed;
}

class ProgressController {
  async listMyEntries(req, res, next) {
    try {
      const { page = 1, limit = 50 } = req.query;
      const result = await progressService.listMyEntries(req.user.id, parseInt(page), parseInt(limit));
      res.json(result.entries);
    } catch (error) {
      next(error);
    }
  }

  async getById(req, res, next) {
    try {
      const entry = await progressService.getById(parseInt(req.params.id), req.user.id);
      res.json(entry);
    } catch (error) {
      next(error);
    }
  }

  async create(req, res, next) {
    try {
      const { exerciseId, exerciseName, weight, reps, sets, durationMinutes, notes, entryDate, intensity, achievement, mood } = req.body;
      const entry = await progressService.create(req.user.id, {
        exerciseId: parseNullableInt(exerciseId),
        exerciseName,
        weight: parseNullableFloat(weight),
        reps: parseNullableInt(reps),
        sets: parseNullableInt(sets),
        durationMinutes: parseNullableInt(durationMinutes),
        notes,
        entryDate,
        intensity,
        achievement,
        mood
      });
      res.status(201).json(entry);
    } catch (error) {
      next(error);
    }
  }

  async update(req, res, next) {
    try {
      const { exerciseId, exerciseName, weight, reps, sets, durationMinutes, notes, entryDate, intensity, achievement, mood } = req.body;
      const entry = await progressService.update(parseInt(req.params.id), req.user.id, {
        exerciseId: parseNullableInt(exerciseId),
        exerciseName,
        weight: parseNullableFloat(weight),
        reps: parseNullableInt(reps),
        sets: parseNullableInt(sets),
        durationMinutes: parseNullableInt(durationMinutes),
        notes,
        entryDate,
        intensity,
        achievement,
        mood
      });
      res.json(entry);
    } catch (error) {
      next(error);
    }
  }

  async delete(req, res, next) {
    try {
      const result = await progressService.delete(parseInt(req.params.id), req.user.id);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }

  async getStats(req, res, next) {
    try {
      const stats = await progressService.getStats(req.user.id);
      res.json(stats);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new ProgressController();