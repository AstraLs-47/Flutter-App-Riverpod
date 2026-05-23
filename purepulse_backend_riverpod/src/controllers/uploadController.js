const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure uploads directory exists
const uploadDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure storage to save files to the 'uploads' folder
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

class UploadController {
  uploadImage(req, res, next) {
    try {
      if (!req.file) {
        return res.status(400).json({ error: 'No image file uploaded' });
      }

      const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
      res.status(201).json({ imageUrl });
    } catch (error) {
      next(error);
    }
  }
}

const uploadController = new UploadController();
uploadController.upload = upload; // Attach multer instance for use in routes

module.exports = uploadController;
