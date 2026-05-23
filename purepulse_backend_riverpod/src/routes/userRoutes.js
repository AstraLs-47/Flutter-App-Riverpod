const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { auth, authorize } = require('../middleware/auth');

router.get('/profile', auth, userController.getProfile);
router.get('/dashboard', auth, userController.getDashboard);
router.put('/profile', auth, userController.updateProfile);
router.post('/onboard', auth, userController.onboard);
router.delete('/account', auth, userController.deleteAccount);

module.exports = router;