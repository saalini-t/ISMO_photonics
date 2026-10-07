require('dotenv').config();

const config = {
  port: process.env.PORT || 3000,
  jwtSecret: process.env.JWT_SECRET,
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '24h',
  nodeEnv: process.env.NODE_ENV || 'development',
  corsOrigin: process.env.CORS_ORIGIN || '*'
};

if (!config.jwtSecret) {
  throw new Error('JWT_SECRET is missing in environment variables');
}
if (!config.port) {
    throw new Error('PORT is missing in environment variables');
}

module.exports = config;
