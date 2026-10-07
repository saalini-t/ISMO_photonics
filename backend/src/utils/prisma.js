const { PrismaClient } = require('@prisma/client');
const config = require('../config');

const prisma = new PrismaClient({
  log: config.nodeEnv === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
});

module.exports = prisma;
