const taskService = require('../services/taskService');

const listTasks = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const result = await taskService.listTasks(userId, req.query);
    res.json({ success: true, ...result });
  } catch (error) {
    next(error);
  }
};

const getTaskById = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const task = await taskService.getTaskById(userId, req.params.id);
    res.json({ success: true, data: task });
  } catch (error) {
    next(error);
  }
};

const createTask = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const task = await taskService.createTask(userId, req.body);
    res.status(201).json({ success: true, data: task });
  } catch (error) {
    next(error);
  }
};

const updateTask = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const task = await taskService.updateTask(userId, req.params.id, req.body);
    res.json({ success: true, data: task });
  } catch (error) {
    next(error);
  }
};

const deleteTask = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const result = await taskService.deleteTask(userId, req.params.id);
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  listTasks,
  getTaskById,
  createTask,
  updateTask,
  deleteTask
};
