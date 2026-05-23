const express = require('express');
const multer = require('multer');
const path = require('path');
const uploadController = require('../controllers/uploadController');
const { auth, authorize } = require('../middleware/auth');

const router = express.Router();
const uploadsDir = path.join(__dirname, '..', '..', 'uploads');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const safeName = file.originalname.replace(/\s+/g, '_');
    const filename = `${Date.now()}-${safeName}`;
    cb(null, filename);
  }
});

const upload = multer({ storage });

router.post('/', auth, authorize('admin'), upload.single('image'), uploadController.uploadImage);

module.exports = router;
