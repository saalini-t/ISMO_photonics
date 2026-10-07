const ApiError = require('../utils/ApiError');

const validate = (schema) => async (req, res, next) => {
  try {
    const parsedData = await schema.parseAsync(req.body);
    req.body = parsedData;
    next();
  } catch (error) {
    if (error.name === 'ZodError') {
      const fieldErrors = error.errors.map(err => ({
        path: err.path.join('.'),
        message: err.message
      }));
      next(ApiError.badRequest('Validation failed', fieldErrors));
    } else {
      next(error);
    }
  }
};

module.exports = validate;
