const rateLimit = require('express-rate-limit');
const ApiError = require('../utils/ApiError');

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  skip: () => process.env.NODE_ENV === 'test',
  handler: (req, res, next) => {
    next(ApiError.tooManyRequests('Too many requests, please try again later.'));
  }
});

const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  skip: () => process.env.NODE_ENV === 'test',
  handler: (req, res, next) => {
    next(ApiError.tooManyRequests('Too many requests, please try again later.'));
  }
});

module.exports = {
  authLimiter,
  generalLimiter
};
