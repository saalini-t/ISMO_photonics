const projectService = require('../services/projectService');

const listProjects = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const result = await projectService.listProjects(userId, req.query);
    res.json({ success: true, ...result });
  } catch (error) {
    next(error);
  }
};

const getProjectById = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const project = await projectService.getProjectById(userId, req.params.id);
    res.json({ success: true, data: project });
  } catch (error) {
    next(error);
  }
};

const createProject = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const project = await projectService.createProject(userId, req.body);
    res.status(201).json({ success: true, data: project });
  } catch (error) {
    next(error);
  }
};

const updateProject = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const project = await projectService.updateProject(userId, req.params.id, req.body);
    res.json({ success: true, data: project });
  } catch (error) {
    next(error);
  }
};

const deleteProject = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const result = await projectService.deleteProject(userId, req.params.id);
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  listProjects,
  getProjectById,
  createProject,
  updateProject,
  deleteProject
};
