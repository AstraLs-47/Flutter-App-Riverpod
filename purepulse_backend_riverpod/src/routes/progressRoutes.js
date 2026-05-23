const express = require('express');
const router = express.Router();
const progressController = require('../controllers/progressController');
const { auth, authorize } = require('../middleware/auth');

router.get('/', auth, progressController.listMyEntries);
router.get('/stats', auth, progressController.getStats);
router.get('/:id', auth, progressController.getById);
router.post('/', auth, progressController.create);
router.put('/:id', auth, progressController.update);
router.delete('/:id', auth, progressController.delete);

module.exports = router;