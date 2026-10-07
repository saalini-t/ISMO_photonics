const logger = require('../utils/logger');
const ApiError = require('../utils/ApiError');
const config = require('../config');

const errorHandler = (err, req, res, next) => {
  logger.error(err);

  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';
  let errors = err.errors || [];

  if (err instanceof ApiError) {
    statusCode = err.statusCode;
    message = err.message;
    errors = err.errors;
  } else if (err.code === 'P2002') {
    statusCode = 409;
    message = 'Resource already exists';
  } else if (err.name === 'PrismaClientValidationError') {
    statusCode = 400;
    message = 'Database validation error';
  } else if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token expired';
  } else if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid token';
  } else if (statusCode === 500 && config.nodeEnv === 'production') {
    message = 'Internal Server Error';
  }

  const response = {
    success: false,
    message
  };

  if (errors.length > 0) {
    response.errors = errors;
  }

  res.status(statusCode).json(response);
};

module.exports = errorHandler;
