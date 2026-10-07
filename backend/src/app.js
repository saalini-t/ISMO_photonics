const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const config = require('./config');
const logger = require('./utils/logger');
const routes = require('./routes');
const errorHandler = require('./middleware/errorHandler');

const app = express();

// Security & parsing middleware
app.use(helmet());
app.use(cors({ origin: config.corsOrigin, credentials: true }));

app.use(morgan('dev', {
  stream: { write: message => logger.info(message.trim()) }
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api', routes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// Global error handler (must be last)
app.use(errorHandler);

module.exports = app;
