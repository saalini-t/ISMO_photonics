const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');
const { paginate, formatPaginatedResponse } = require('../utils/pagination');

const listProjects = async (userId, queryParams) => {
  const { page, limit, search, status, sortBy, sortOrder } = queryParams;
  const { skip, take, page: parsedPage, limit: parsedLimit } = paginate(page, limit);

  const where = {
    userId,
    ...(status && { status }),
    ...(search && {
      name: {
        contains: search,
        mode: 'insensitive'
      }
    })
  };

  const [items, totalCount] = await Promise.all([
    prisma.project.findMany({
      where,
      skip,
      take,
      orderBy: {
        [sortBy]: sortOrder
      },
      include: {
        _count: {
          select: { tasks: true }
        }
      }
    }),
    prisma.project.count({ where })
  ]);

  return formatPaginatedResponse(items, totalCount, parsedPage, parsedLimit);
};

const getProjectById = async (userId, projectId) => {
  const project = await prisma.project.findFirst({
    where: {
      id: projectId,
      userId
    },
    include: {
      tasks: {
        orderBy: {
          createdAt: 'desc'
        }
      }
    }
  });

  if (!project) {
    throw ApiError.notFound('Project not found');
  }

  return project;
};

const createProject = async (userId, data) => {
  const project = await prisma.project.create({
    data: {
      ...data,
      userId
    }
  });
  return project;
};

const updateProject = async (userId, projectId, data) => {
  const existingProject = await prisma.project.findFirst({
    where: { id: projectId, userId }
  });

  if (!existingProject) {
    throw ApiError.notFound('Project not found');
  }

  const project = await prisma.project.update({
    where: { id: projectId },
    data
  });

  return project;
};

const deleteProject = async (userId, projectId) => {
  const existingProject = await prisma.project.findFirst({
    where: { id: projectId, userId }
  });

  if (!existingProject) {
    throw ApiError.notFound('Project not found');
  }

  await prisma.project.delete({
    where: { id: projectId }
  });

  return { message: 'Project deleted successfully', id: projectId };
};

module.exports = {
  listProjects,
  getProjectById,
  createProject,
  updateProject,
  deleteProject
};
