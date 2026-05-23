const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const exerciseRoutes = require('./routes/exerciseRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const progressRoutes = require('./routes/progressRoutes');
const healthRoutes = require('./routes/healthRoutes');
const productRoutes = require('./routes/productRoutes');
const announcementRoutes = require('./routes/announcementRoutes');
const adminRoutes = require('./routes/adminRoutes');
const uploadRoutes = require('./routes/uploadRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Ensure upload directory exists
const uploadsDir = path.join(__dirname, '..', 'uploads');
try {
  if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
  }
} catch (err) {
  console.error('Error creating uploads directory:', err);
}

// Static files for uploads
app.use('/uploads', express.static(uploadsDir));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/exercises', exerciseRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/progress', progressRoutes);
app.use('/api/health', healthRoutes);
app.use('/api/products', productRoutes);
app.use('/api/announcements', announcementRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/uploads', uploadRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'PurePulse API is running' });
});

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

// Global error handling to prevent immediate termination without logs
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
});

// Start server
const server = app.listen(PORT, () => {
  console.log(`PurePulse server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Handle server-level errors (like EADDRINUSE)
server.on('error', (error) => {
  console.error('Server startup error:', error);
});

module.exports = app;