module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.js'],
  collectCoverageFrom: ['src/**/*.js', '!src/server.js'],
  coverageDirectory: 'coverage',
  setupFilesAfterEnv: ['./tests/setup.js'],
  testTimeout: 30000,
  verbose: true,
};
