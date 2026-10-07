const rateLimit = require('express-rate-limit');
const ApiError = require('../utils/ApiError');

const isTest = process.env.NODE_ENV === 'test';

// Skip rate limiting in test environment
const passThrough = (req, res, next) => next();

const authLimiter = isTest
  ? passThrough
  : rateLimit({
      windowMs: 15 * 60 * 1000,
      max: 10,
      handler: (req, res, next) => {
        next(ApiError.tooManyRequests('Too many requests, please try again later.'));
      }
    });

const generalLimiter = isTest
  ? passThrough
  : rateLimit({
      windowMs: 15 * 60 * 1000,
      max: 100,
      handler: (req, res, next) => {
        next(ApiError.tooManyRequests('Too many requests, please try again later.'));
      }
    });

module.exports = {
  authLimiter,
  generalLimiter
};
