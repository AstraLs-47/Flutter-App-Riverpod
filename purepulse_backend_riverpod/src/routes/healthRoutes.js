const express = require('express');
const router = express.Router();
const healthController = require('../controllers/healthController');
const { auth, authorize } = require('../middleware/auth');

router.get('/latest', auth, healthController.getLatestMetrics);
router.get('/', auth, healthController.listHistory);
router.get('/:id', auth, healthController.getById);
router.post('/', auth, healthController.addEntry);
router.put('/:id', auth, healthController.updateMetrics);
router.delete('/:id', auth, healthController.deleteEntry);

module.exports = router;