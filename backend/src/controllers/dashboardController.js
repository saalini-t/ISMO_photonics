const dashboardService = require('../services/dashboardService');

const getDashboard = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const stats = await dashboardService.getDashboardStats(userId);
    res.json({ success: true, data: stats });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getDashboard
};
