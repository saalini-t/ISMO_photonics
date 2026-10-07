const { z } = require('zod');

const projectStatuses = ['NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'];

const createProjectSchema = z.object({
  name: z.string().min(1).max(150),
  description: z.string().nullable().optional(),
  status: z.enum(projectStatuses).optional().default('NOT_STARTED'),
  startDate: z.coerce.date().nullable().optional(),
  endDate: z.coerce.date().nullable().optional()
}).refine(data => {
  if (data.startDate && data.endDate) {
    return data.endDate >= data.startDate;
  }
  return true;
}, {
  message: "endDate must be greater than or equal to startDate",
  path: ["endDate"]
});

const updateProjectSchema = z.object({
  name: z.string().min(1).max(150).optional(),
  description: z.string().nullable().optional(),
  status: z.enum(projectStatuses).optional(),
  startDate: z.coerce.date().nullable().optional(),
  endDate: z.coerce.date().nullable().optional()
}).refine(data => {
  if (data.startDate && data.endDate) {
    return data.endDate >= data.startDate;
  }
  return true;
}, {
  message: "endDate must be greater than or equal to startDate",
  path: ["endDate"]
});

const projectQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(10),
  search: z.string().optional(),
  status: z.enum(projectStatuses).optional(),
  sortBy: z.enum(['createdAt', 'name', 'status', 'startDate', 'endDate']).default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('desc')
});

module.exports = {
  createProjectSchema,
  updateProjectSchema,
  projectQuerySchema
};
