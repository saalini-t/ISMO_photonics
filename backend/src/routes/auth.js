const express = require('express');
const router = express.Router();

const authController = require('../controllers/authController');
const validate = require('../middleware/validate');
const { authLimiter } = require('../middleware/rateLimiter');
const authenticate = require('../middleware/auth');
const { registerSchema, loginSchema } = require('../validators/authValidator');

router.post('/register', authLimiter, validate(registerSchema), authController.register);
router.post('/login', authLimiter, validate(loginSchema), authController.login);
router.post('/logout', authenticate, authController.logout);
router.get('/me', authenticate, authController.getMe);

module.exports = router;
