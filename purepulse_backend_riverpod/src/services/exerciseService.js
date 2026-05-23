const Exercise = require('../models/Exercise');

class ExerciseService {
  async list(categoryId, difficulty, page = 1, limit = 50) {
    const offset = (page - 1) * limit;
    const exercises = await Exercise.findAll(categoryId, difficulty, limit, offset);
    const total = await Exercise.count(categoryId, difficulty);

    return {
      exercises: exercises.map(e => this.formatExercise(e)),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) }
    };
  }

  async getById(id) {
    const exercise = await Exercise.findById(id);
    if (!exercise) {
      const error = new Error('Exercise not found');
      error.statusCode = 404;
      throw error;
    }
    return this.formatExercise(exercise);
  }

  async create(data) {
    const exercise = await Exercise.create(data);
    return this.formatExercise(exercise);
  }

  async update(id, data) {
    const existing = await Exercise.findById(id);
    if (!existing) {
      const error = new Error('Exercise not found');
      error.statusCode = 404;
      throw error;
    }
    const exercise = await Exercise.update(id, data);
    return this.formatExercise(exercise);
  }

  async delete(id) {
    const existing = await Exercise.findById(id);
    if (!existing) {
      const error = new Error('Exercise not found');
      error.statusCode = 404;
      throw error;
    }
    await Exercise.delete(id);
    return { message: 'Exercise deleted successfully' };
  }

  formatExercise(exercise) {
    return {
      id: exercise.id,
      title: exercise.name,
      description: exercise.description,
      categoryId: exercise.category_id,
      category: exercise.category_name,
      difficulty: exercise.difficulty,
      caloriesPerMinute: exercise.calories_per_minute,
      warmup: exercise.warmup,
      mainWorkout: exercise.main_workout || exercise.mainWorkout,
      rest: exercise.rest,
      duration: exercise.duration,
      imageUrl: exercise.image_url || exercise.image,
      image: exercise.image_url || exercise.image,
      createdBy: exercise.created_by,
      createdAt: exercise.created_at,
      updatedAt: exercise.updated_at
    };
  }
}

module.exports = new ExerciseService();