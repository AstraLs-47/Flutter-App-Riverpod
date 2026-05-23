const express = require('express');
const router = express.Router();
const exerciseController = require('../controllers/exerciseController');
const { auth, authorize } = require('../middleware/auth');

router.get('/', exerciseController.list);
router.get('/:id', exerciseController.getById);
router.post('/', auth, authorize('admin'), exerciseController.create);
router.put('/:id', auth, authorize('admin'), exerciseController.update);
router.delete('/:id', auth, authorize('admin'), exerciseController.delete);

module.exports = router;