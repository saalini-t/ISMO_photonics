const app = require('./app');
const config = require('./config');
const logger = require('./utils/logger');
const prisma = require('./utils/prisma');

const server = app.listen(config.port, () => {
  logger.info(`Server started on port ${config.port} in ${config.nodeEnv} mode`);
});

const gracefulShutdown = async (signal) => {
  logger.info(`Received ${signal}. Shutting down gracefully...`);
  server.close(async () => {
    logger.info('HTTP server closed.');
    await prisma.$disconnect();
    logger.info('Prisma disconnected.');
    process.exit(0);
  });
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
