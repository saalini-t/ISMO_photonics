const ApiError = require('../utils/ApiError');

const validate = (schema, source = 'body') => async (req, res, next) => {
  try {
    const parsedData = await schema.parseAsync(req[source]);
    req[source] = parsedData;
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
