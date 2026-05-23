const jwt = require('jsonwebtoken');

const auth = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      const error = new Error('No token provided');
      error.statusCode = 401;
      return next(error);
    }

    const token = authHeader.split(' ')[1];
    
    const decoded = jwt.verify(
      token, 
      process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production'
    );
    
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      error.message = 'Token has expired';
      error.statusCode = 401;
    } else if (error.name === 'JsonWebTokenError') {
      error.message = 'Invalid token';
      error.statusCode = 401;
    }
    next(error);
  }
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      const error = new Error('Not authenticated');
      error.statusCode = 401;
      return next(error);
    }

    if (!roles.includes(req.user.role)) {
      const error = new Error('Access denied');
      error.statusCode = 403;
      return next(error);
    }

    next();
  };
};

module.exports = { auth, authorize};