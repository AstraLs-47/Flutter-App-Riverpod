const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const { auth, authorize } = require('../middleware/auth');

router.get('/', categoryController.list);
router.post('/', auth, authorize('admin'), categoryController.create);
router.delete('/:id', auth, authorize('admin'), categoryController.delete);

module.exports = router;