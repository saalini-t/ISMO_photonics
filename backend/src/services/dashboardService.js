const prisma = require('../utils/prisma');

const getDashboardStats = async (userId) => {
  const [
    totalProjects,
    projectsInProgress,
    totalTasks,
    completedTasks,
    pendingTasks,
    tasksInProgress
  ] = await Promise.all([
    prisma.project.count({
      where: { userId }
    }),
    prisma.project.count({
      where: { userId, status: 'IN_PROGRESS' }
    }),
    prisma.task.count({
      where: { project: { userId } }
    }),
    prisma.task.count({
      where: { project: { userId }, status: 'COMPLETED' }
    }),
    prisma.task.count({
      where: { project: { userId }, status: 'PENDING' }
    }),
    prisma.task.count({
      where: { project: { userId }, status: 'IN_PROGRESS' }
    })
  ]);

  return {
    totalProjects,
    projectsInProgress,
    totalTasks,
    completedTasks,
    pendingTasks,
    tasksInProgress
  };
};

module.exports = {
  getDashboardStats
};
