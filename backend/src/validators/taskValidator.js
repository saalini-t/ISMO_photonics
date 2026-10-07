const { z } = require('zod');

const taskStatuses = ['PENDING', 'IN_PROGRESS', 'COMPLETED'];
const taskPriorities = ['LOW', 'MEDIUM', 'HIGH'];

const createTaskSchema = z.object({
  name: z.string().min(1).max(150),
  description: z.string().nullable().optional(),
  priority: z.enum(taskPriorities).default('MEDIUM'),
  status: z.enum(taskStatuses).default('PENDING'),
  dueDate: z.coerce.date().nullable().optional(),
  projectId: z.string().uuid()
});

const updateTaskSchema = z.object({
  name: z.string().min(1).max(150).optional(),
  description: z.string().nullable().optional(),
  priority: z.enum(taskPriorities).optional(),
  status: z.enum(taskStatuses).optional(),
  dueDate: z.coerce.date().nullable().optional(),
  projectId: z.string().uuid().optional()
});

const taskQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(10),
  search: z.string().optional(),
  status: z.enum(taskStatuses).optional(),
  priority: z.enum(taskPriorities).optional(),
  projectId: z.string().uuid().optional(),
  sortBy: z.enum(['createdAt', 'name', 'dueDate', 'priority', 'status']).default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('desc')
});

module.exports = {
  createTaskSchema,
  updateTaskSchema,
  taskQuerySchema
};
