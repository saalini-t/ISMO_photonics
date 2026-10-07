const request = require('supertest');
const app = require('../../src/app');
const prisma = require('../../src/utils/prisma');

describe('Tasks Endpoints', () => {
  const userA = {
    fullName: 'User A',
    email: 'taska@example.com',
    password: 'password123'
  };

  const userB = {
    fullName: 'User B',
    email: 'taskb@example.com',
    password: 'password123'
  };

  let tokenA = '';
  let tokenB = '';
  let projectAId = '';
  let projectBId = '';

  beforeAll(async () => {
    await prisma.$connect();
  });

  beforeEach(async () => {
    // Clean DB
    await prisma.task.deleteMany();
    await prisma.project.deleteMany();
    await prisma.user.deleteMany();

    // Register User A
    const resA = await request(app).post('/api/auth/register').send(userA);
    tokenA = resA.body.data.token;

    // Register User B
    const resB = await request(app).post('/api/auth/register').send(userB);
    tokenB = resB.body.data.token;

    // Create Project A
    const pA = await request(app)
      .post('/api/projects')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ name: 'Project A' });
    projectAId = pA.body.data.id;

    // Create Project B
    const pB = await request(app)
      .post('/api/projects')
      .set('Authorization', `Bearer ${tokenB}`)
      .send({ name: 'Project B' });
    projectBId = pB.body.data.id;
  });

  afterAll(async () => {
    await prisma.task.deleteMany();
    await prisma.project.deleteMany();
    await prisma.user.deleteMany();
    await prisma.$disconnect();
  });

  describe('POST /api/tasks', () => {
    it('Should create task under owned project (201)', async () => {
      const res = await request(app)
        .post('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({
          name: 'Task 1', // Based on Prisma schema name
          title: 'Task 1 Title', // Include title based on requirement
          projectId: projectAId
        });

      expect(res.status).toBe(201);
    });

    it('Should fail validation with missing title/projectId (400)', async () => {
      const res = await request(app)
        .post('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({
          name: 'Task without projectId and title'
        });

      expect(res.status).toBe(400);
    });

    it('Should fail when trying to create task in another user project', async () => {
      const res = await request(app)
        .post('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({
          name: 'Hacked Task',
          title: 'Hacked Task Title',
          projectId: projectBId
        });

      expect([403, 404]).toContain(res.status);
    });
  });

  describe('GET /api/tasks', () => {
    beforeEach(async () => {
      await request(app)
        .post('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Task Alpha', title: 'Task Alpha', projectId: projectAId, status: 'PENDING', priority: 'HIGH' });
      await request(app)
        .post('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Task Beta', title: 'Task Beta', projectId: projectAId, status: 'COMPLETED', priority: 'LOW' });
      
      await request(app)
        .post('/api/tasks')
        .set('Authorization', `Bearer ${tokenB}`)
        .send({ name: 'Task Gamma', title: 'Task Gamma', projectId: projectBId });
    });

    it('Should list tasks belonging only to user projects', async () => {
      const res = await request(app)
        .get('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(2);
    });

    it('Should filter by status, priority, projectId', async () => {
      const res = await request(app)
        .get(`/api/tasks?status=COMPLETED&priority=LOW&projectId=${projectAId}`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.data[0].name).toBe('Task Beta');
    });

    it('Should search by name', async () => {
      const res = await request(app)
        .get('/api/tasks?search=Alpha')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.data[0].name).toBe('Task Alpha');
    });

    it('Should include pagination structure', async () => {
      const res = await request(app)
        .get('/api/tasks?page=1&limit=1')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
      expect(res.body.pagination).toBeDefined();
      expect(res.body.pagination.totalCount).toBe(2);
      expect(res.body.data.length).toBe(1);
    });
  });

  describe('GET /api/tasks/:id', () => {
    let taskAId = '';

    beforeEach(async () => {
      const res = await request(app)
        .post('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Specific Task', title: 'Specific Task', projectId: projectAId });
      taskAId = res.body.data.id;
    });

    it('Should get task (200)', async () => {
      const res = await request(app)
        .get(`/api/tasks/${taskAId}`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
      expect(res.body.data.id).toBe(taskAId);
    });

    it('Should return 404/403 if User B requests User A task', async () => {
      const res = await request(app)
        .get(`/api/tasks/${taskAId}`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect([403, 404]).toContain(res.status);
    });
  });

  describe('PUT /api/tasks/:id', () => {
    let taskAId = '';

    beforeEach(async () => {
      const res = await request(app)
        .post('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Updatable Task', title: 'Updatable Task', projectId: projectAId });
      taskAId = res.body.data.id;
    });

    it('Should update task status, priority, details (200)', async () => {
      const res = await request(app)
        .put(`/api/tasks/${taskAId}`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ status: 'IN_PROGRESS', priority: 'HIGH', name: 'Updated Name' });

      expect(res.status).toBe(200);
      expect(res.body.data.status).toBe('IN_PROGRESS');
      expect(res.body.data.priority).toBe('HIGH');
    });

    it('Should return 404/403 if User B tries to update User A task', async () => {
      const res = await request(app)
        .put(`/api/tasks/${taskAId}`)
        .set('Authorization', `Bearer ${tokenB}`)
        .send({ status: 'COMPLETED' });

      expect([403, 404]).toContain(res.status);
    });
  });

  describe('DELETE /api/tasks/:id', () => {
    let taskAId = '';

    beforeEach(async () => {
      const res = await request(app)
        .post('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Deletable Task', title: 'Deletable Task', projectId: projectAId });
      taskAId = res.body.data.id;
    });

    it('Should delete task (200)', async () => {
      const res = await request(app)
        .delete(`/api/tasks/${taskAId}`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
    });

    it('Should return 404/403 if User B tries to delete User A task', async () => {
      const res = await request(app)
        .delete(`/api/tasks/${taskAId}`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect([403, 404]).toContain(res.status);
    });
  });
});
