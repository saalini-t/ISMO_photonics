const express = require('express');
const router = express.Router();

const taskController = require('../controllers/taskController');
const { authenticate } = require('../middleware/auth');
const validate = require('../middleware/validate');
const { createTaskSchema, updateTaskSchema, taskQuerySchema } = require('../validators/taskValidator');

router.use(authenticate);

router.get('/', validate(taskQuerySchema, 'query'), taskController.listTasks);
router.post('/', validate(createTaskSchema, 'body'), taskController.createTask);
router.get('/:id', taskController.getTaskById);
router.put('/:id', validate(updateTaskSchema, 'body'), taskController.updateTask);
router.delete('/:id', taskController.deleteTask);

module.exports = router;
