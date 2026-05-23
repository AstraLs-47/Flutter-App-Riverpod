const healthService = require('../services/healthService');

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

class HealthController {
  async getLatestMetrics(req, res, next) {
    try {
      const metrics = await healthService.getLatestMetrics(req.user.id);
      if (!metrics) {
        return res.status(404).json({ error: 'No health metrics found' });
      }
      res.json(metrics);
    } catch (error) {
      next(error);
    }
  }

  async getById(req, res, next) {
    try {
      const metrics = await healthService.getById(parseInt(req.params.id), req.user.id);
      res.json(metrics);
    } catch (error) {
      next(error);
    }
  }

  async listHistory(req, res, next) {
    try {
      const { page = 1, limit = 50 } = req.query;
      const result = await healthService.listHistory(req.user.id, parseInt(page), parseInt(limit));
      res.json(result);
    } catch (error) {
      next(error);
    }
  }

  async addEntry(req, res, next) {
    try {
      const { weight, height, restingHeartRate, heartRate, bloodPressureSystolic, bloodPressureDiastolic, bloodSugar, measurementDate } = req.body;
      const entry = await healthService.addEntry(req.user.id, {
        weight: parseNullableFloat(weight),
        height: parseNullableFloat(height),
        restingHeartRate: parseNullableInt(restingHeartRate) ?? parseNullableInt(heartRate),
        bloodPressureSystolic: parseNullableInt(bloodPressureSystolic),
        bloodPressureDiastolic: parseNullableInt(bloodPressureDiastolic),
        bloodSugar: parseNullableFloat(bloodSugar),
        measurementDate
      });
      res.status(201).json(entry);
    } catch (error) {
      next(error);
    }
  }

  async updateMetrics(req, res, next) {
    try {
      const { weight, height, restingHeartRate, heartRate, bloodPressureSystolic, bloodPressureDiastolic, bloodSugar, measurementDate } = req.body;
      const entry = await healthService.updateMetrics(parseInt(req.params.id), req.user.id, {
        weight: parseNullableFloat(weight),
        height: parseNullableFloat(height),
        restingHeartRate: parseNullableInt(restingHeartRate) ?? parseNullableInt(heartRate),
        bloodPressureSystolic: parseNullableInt(bloodPressureSystolic),
        bloodPressureDiastolic: parseNullableInt(bloodPressureDiastolic),
        bloodSugar: parseNullableFloat(bloodSugar),
        measurementDate
      });
      res.json(entry);
    } catch (error) {
      next(error);
    }
  }

  async deleteEntry(req, res, next) {
    try {
      const result = await healthService.deleteEntry(parseInt(req.params.id), req.user.id);
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new HealthController();