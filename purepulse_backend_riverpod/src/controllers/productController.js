const productService = require('../services/productService');

class ProductController {
  async list(req, res, next) {
    try {
      const { page = 1, limit = 50 } = req.query;
      const result = await productService.list(parseInt(page), parseInt(limit));
      res.json(result.products);
    } catch (error) {
      next(error);
    }
  }

  async getById(req, res, next) {
    try {
      const product = await productService.getById(parseInt(req.params.id));
      res.json(product);
    } catch (error) {
      next(error);
    }
  }

  async create(req, res, next) {
    try {
      const { name, description, category, imageUrl, image } = req.body;
      if (!name) {
        return res.status(400).json({ error: 'Name is required' });
      }
      const product = await productService.create({
        name,
        description,
        category,
        imageUrl: imageUrl || image,
        image: image || imageUrl,
        createdBy: req.user.id
      });
      res.status(201).json(product);
    } catch (error) {
      next(error);
    }
  }

  async update(req, res, next) {
    try {
      const { name, description, category, imageUrl, image, isActive } = req.body;
      const product = await productService.update(parseInt(req.params.id), {
        name,
        description,
        category,
        imageUrl: imageUrl || image,
        image: image || imageUrl,
        isActive
      });
      res.json(product);
    } catch (error) {
      next(error);
    }
  }

  async delete(req, res, next) {
    try {
      const result = await productService.delete(parseInt(req.params.id));
      res.json(result);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new ProductController();