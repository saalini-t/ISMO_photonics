require('dotenv').config();
process.env.NODE_ENV = 'test';

const prisma = require('../src/utils/prisma');

beforeAll(async () => {
  await prisma.$connect();
});

beforeEach(async () => {
  // Clean the database between test runs
  await prisma.$transaction([
    prisma.task.deleteMany(),
    prisma.project.deleteMany(),
    prisma.user.deleteMany()
  ]);
});

afterAll(async () => {
  await prisma.$disconnect();
});
