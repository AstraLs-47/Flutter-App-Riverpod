const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const { auth, authorize } = require('../middleware/auth');

router.get('/', productController.list);
router.get('/:id', productController.getById);
router.post('/', auth, authorize('admin'), productController.create);
router.put('/:id', auth, authorize('admin'), productController.update);
router.delete('/:id', auth, authorize('admin'), productController.delete);

module.exports = router;