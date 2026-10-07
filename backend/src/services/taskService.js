const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');
const { paginate, formatPaginatedResponse } = require('../utils/pagination');

const listTasks = async (userId, queryParams) => {
  const { page, limit, search, status, priority, projectId, sortBy, sortOrder } = queryParams;
  const { skip, take, page: parsedPage, limit: parsedLimit } = paginate(page, limit);

  const where = {
    project: {
      userId
    },
    ...(status && { status }),
    ...(priority && { priority }),
    ...(projectId && { projectId }),
    ...(search && {
      name: {
        contains: search,
        mode: 'insensitive'
      }
    })
  };

  const [items, totalCount] = await Promise.all([
    prisma.task.findMany({
      where,
      skip,
      take,
      orderBy: {
        [sortBy]: sortOrder
      },
      include: {
        project: {
          select: {
            id: true,
            name: true
          }
        }
      }
    }),
    prisma.task.count({ where })
  ]);

  return formatPaginatedResponse(items, totalCount, parsedPage, parsedLimit);
};

const getTaskById = async (userId, taskId) => {
  const task = await prisma.task.findFirst({
    where: {
      id: taskId,
      project: {
        userId
      }
    },
    include: {
      project: {
        select: {
          id: true,
          name: true
        }
      }
    }
  });

  if (!task) {
    throw ApiError.notFound('Task not found');
  }

  return task;
};

const createTask = async (userId, data) => {
  const project = await prisma.project.findFirst({
    where: {
      id: data.projectId,
      userId
    }
  });

  if (!project) {
    throw ApiError.notFound('Project not found');
  }

  const task = await prisma.task.create({
    data,
    include: {
      project: {
        select: {
          id: true,
          name: true
        }
      }
    }
  });

  return task;
};

const updateTask = async (userId, taskId, data) => {
  const task = await prisma.task.findFirst({
    where: {
      id: taskId,
      project: {
        userId
      }
    }
  });

  if (!task) {
    throw ApiError.notFound('Task not found');
  }

  if (data.projectId) {
    const targetProject = await prisma.project.findFirst({
      where: {
        id: data.projectId,
        userId
      }
    });

    if (!targetProject) {
      throw ApiError.notFound('Target project not found');
    }
  }

  const updatedTask = await prisma.task.update({
    where: { id: taskId },
    data,
    include: {
      project: {
        select: {
          id: true,
          name: true
        }
      }
    }
  });

  return updatedTask;
};

const deleteTask = async (userId, taskId) => {
  const task = await prisma.task.findFirst({
    where: {
      id: taskId,
      project: {
        userId
      }
    }
  });

  if (!task) {
    throw ApiError.notFound('Task not found');
  }

  await prisma.task.delete({
    where: { id: taskId }
  });

  return { message: 'Task deleted successfully', id: taskId };
};

module.exports = {
  listTasks,
  getTaskById,
  createTask,
  updateTask,
  deleteTask
};
