const express = require('express');
const router = express.Router();

const projectController = require('../controllers/projectController');
const { authenticate } = require('../middleware/auth');
const validate = require('../middleware/validate');
const { createProjectSchema, updateProjectSchema, projectQuerySchema } = require('../validators/projectValidator');

router.use(authenticate);

router.get('/', validate(projectQuerySchema, 'query'), projectController.listProjects);
router.post('/', validate(createProjectSchema, 'body'), projectController.createProject);
router.get('/:id', projectController.getProjectById);
router.put('/:id', validate(updateProjectSchema, 'body'), projectController.updateProject);
router.delete('/:id', projectController.deleteProject);

module.exports = router;
