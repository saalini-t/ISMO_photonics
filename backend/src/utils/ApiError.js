class ApiError extends Error {
  constructor(statusCode, message, errors = []) {
    super(message);
    this.statusCode = statusCode;
    this.message = message;
    this.errors = errors;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }

  static badRequest(msg, errors = []) {
    return new ApiError(400, msg, errors);
  }

  static unauthorized(msg) {
    return new ApiError(401, msg);
  }

  static forbidden(msg) {
    return new ApiError(403, msg);
  }

  static notFound(msg) {
    return new ApiError(404, msg);
  }

  static conflict(msg) {
    return new ApiError(409, msg);
  }

  static tooManyRequests(msg) {
    return new ApiError(429, msg);
  }

  static internal(msg) {
    return new ApiError(500, msg);
  }
}

module.exports = ApiError;
