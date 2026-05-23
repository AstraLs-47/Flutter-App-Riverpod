const Category = require('../models/Category');

class CategoryService {
  async list(type = null) {
    const categories = await Category.findAll(type);
    return categories.map(c => this.formatCategory(c));
  }

  async getById(id) {
    const category = await Category.findById(id);
    if (!category) {
      const error = new Error('Category not found');
      error.statusCode = 404;
      throw error;
    }
    return this.formatCategory(category);
  }

  async create(data) {
    const category = await Category.create(data);
    return this.formatCategory(category);
  }

  async delete(id) {
    const existing = await Category.findById(id);
    if (!existing) {
      const error = new Error('Category not found');
      error.statusCode = 404;
      throw error;
    }
    await Category.delete(id);
    return { message: 'Category deleted successfully' };
  }

  formatCategory(category) {
    return {
      id: category.id,
      name: category.name,
      type: category.type || 'general',
      createdAt: category.created_at
    };
  }
}

module.exports = new CategoryService();