const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { auth, authorize } = require('../middleware/auth');

router.post('/signup', authController.signup);
router.post('/signin', authController.signin);
router.post('/signout', auth, authController.signout);
router.get('/me', auth, authController.getCurrentUser);

module.exports = router;