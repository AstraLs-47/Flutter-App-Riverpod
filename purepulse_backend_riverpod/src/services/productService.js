const Product = require('../models/Product');

class ProductService {
  async list(page = 1, limit = 50) {
    const offset = (page - 1) * limit;
    const products = await Product.findAll(limit, offset);
    const total = await Product.count();

    return {
      products: products.map(p => this.formatProduct(p)),
      pagination: { page, limit, total, pages: Math.ceil(total / limit) }
    };
  }

  async getById(id) {
    const product = await Product.findById(id);
    if (!product) {
      const error = new Error('Product not found');
      error.statusCode = 404;
      throw error;
    }
    return this.formatProduct(product);
  }

  async create(data) {
    const product = await Product.create(data);
    return this.formatProduct(product);
  }

  async update(id, data) {
    const existing = await Product.findById(id);
    if (!existing) {
      const error = new Error('Product not found');
      error.statusCode = 404;
      throw error;
    }
    const product = await Product.update(id, data);
    return this.formatProduct(product);
  }

  async delete(id) {
    const existing = await Product.findById(id);
    if (!existing) {
      const error = new Error('Product not found');
      error.statusCode = 404;
      throw error;
    }
    await Product.delete(id);
    return { message: 'Product deleted successfully' };
  }

  formatProduct(product) {
    return {
      id: product.id,
      name: product.name,
      description: product.description,
      category: product.category,
      imageUrl: product.image_url,
      image: product.image_url,
      isActive: product.is_active,
      createdBy: product.created_by,
      createdAt: product.created_at,
      updatedAt: product.updated_at
    };
  }
}

module.exports = new ProductService();