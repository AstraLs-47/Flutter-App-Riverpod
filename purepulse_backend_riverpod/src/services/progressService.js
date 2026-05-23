const ProgressEntry = require('../models/ProgressEntry');

class ProgressService {
  async listMyEntries(userId, page = 1, limit = 50) {
    const offset = (page - 1) * limit;
    const entries = await ProgressEntry.findByUserId(userId, limit, offset);
    const total = await ProgressEntry.count(userId);

    return {
      entries: entries.map(e => this.formatEntry(e)),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) }
    };
  }

  async getById(id, userId) {
    const entry = await ProgressEntry.findById(id, userId);
    if (!entry) {
      const error = new Error('Progress entry not found');
      error.statusCode = 404;
      throw error;
    }
    return this.formatEntry(entry);
  }

  async create(userId, data) {
    const entry = await ProgressEntry.create(userId, data);
    return this.formatEntry(entry);
  }

  async update(id, userId, data) {
    const existing = await ProgressEntry.findById(id, userId);
    if (!existing) {
      const error = new Error('Progress entry not found');
      error.statusCode = 404;
      throw error;
    }
    const entry = await ProgressEntry.update(id, userId, data);
    return this.formatEntry(entry);
  }

  async delete(id, userId) {
    const existing = await ProgressEntry.findById(id, userId);
    if (!existing) {
      const error = new Error('Progress entry not found');
      error.statusCode = 404;
      throw error;
    }
    await ProgressEntry.delete(id, userId);
    return { message: 'Progress entry deleted successfully' };
  }

  async getStats(userId) {
    const stats = await ProgressEntry.getStats(userId);
    return {
      totalEntries: parseInt(stats.total_entries) || 0,
      totalMinutes: parseInt(stats.total_minutes) || 0,
      totalVolume: parseFloat(stats.total_volume) || 0,
      lastEntryDate: stats.last_entry_date,
      exercisesUsed: parseInt(stats.exercises_used) || 0
    };
  }

  formatEntry(entry) {
    return {
      id: entry.id,
      userId: entry.user_id,
      exerciseId: entry.exercise_id,
      exerciseName: entry.exercise_name,
      exerciseImage: entry.exercise_image,
      weight: entry.weight,
      reps: entry.reps,
      sets: entry.sets,
      durationMinutes: entry.duration_minutes,
      notes: entry.notes,
      intensity: entry.intensity,
      achievement: entry.achievement,
      mood: entry.mood,
      entryDate: entry.entry_date,
      createdAt: entry.created_at,
      updatedAt: entry.updated_at
    };
  }
}

module.exports = new ProgressService();