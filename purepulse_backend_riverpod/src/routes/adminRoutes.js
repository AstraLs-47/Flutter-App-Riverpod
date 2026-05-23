const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { auth, authorize } = require('../middleware/auth');

router.get('/dashboard', auth, authorize('admin'), adminController.getDashboard);
router.get('/users/stats', auth, authorize('admin'), adminController.getUserStats);
router.get('/exercises/stats', auth, authorize('admin'), adminController.getExerciseStats);
router.get('/progress/stats', auth, authorize('admin'), adminController.getProgressStats);
router.get('/health/stats', auth, authorize('admin'), adminController.getHealthStats);
router.get('/products/stats', auth, authorize('admin'), adminController.getProductStats);
router.get('/activity/logs', auth, authorize('admin'), adminController.getActivityLogs);
router.get('/activity/stats', auth, authorize('admin'), adminController.getActivityStats);

module.exports = router;