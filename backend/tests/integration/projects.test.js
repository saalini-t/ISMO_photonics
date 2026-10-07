const request = require('supertest');
const app = require('../../src/app');
const prisma = require('../../src/utils/prisma');

describe('Projects Endpoints', () => {
  const userA = {
    fullName: 'User A',
    email: 'usera@example.com',
    password: 'password123'
  };

  const userB = {
    fullName: 'User B',
    email: 'userb@example.com',
    password: 'password123'
  };

  let tokenA = '';
  let tokenB = '';

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
  });

  afterAll(async () => {
    await prisma.task.deleteMany();
    await prisma.project.deleteMany();
    await prisma.user.deleteMany();
    await prisma.$disconnect();
  });

  describe('POST /api/projects', () => {
    it('Should create project with valid fields (201)', async () => {
      const res = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({
          name: 'Project A1',
          description: 'A great project'
        });

      expect(res.status).toBe(201);
      expect(res.body.data.name).toBe('Project A1');
    });

    it('Should fail validation with missing name (400)', async () => {
      const res = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({
          description: 'No name provided'
        });

      expect(res.status).toBe(400);
    });

    it('Should be unauthorized without token (401)', async () => {
      const res = await request(app)
        .post('/api/projects')
        .send({
          name: 'Project No Auth'
        });

      expect(res.status).toBe(401);
    });
  });

  describe('GET /api/projects', () => {
    beforeEach(async () => {
      await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Alpha', status: 'IN_PROGRESS' });
      await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Beta', status: 'COMPLETED' });
      
      await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${tokenB}`)
        .send({ name: 'Gamma', status: 'NOT_STARTED' });
    });

    it('Should return paginated list belonging ONLY to the requesting user', async () => {
      const res = await request(app)
        .get('/api/projects')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(2);
      expect(res.body.pagination).toBeDefined();
    });

    it('Should search by name filter', async () => {
      const res = await request(app)
        .get('/api/projects?search=Alpha')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.data[0].name).toBe('Alpha');
    });

    it('Should filter by status', async () => {
      const res = await request(app)
        .get('/api/projects?status=COMPLETED')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.data[0].name).toBe('Beta');
    });

    it('Should include pagination parameters', async () => {
      const res = await request(app)
        .get('/api/projects?page=1&limit=1')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
      expect(res.body.pagination.page).toBe(1);
      expect(res.body.pagination.limit).toBe(1);
      expect(res.body.pagination.totalCount).toBe(2);
      expect(res.body.pagination.totalPages).toBe(2);
      expect(res.body.data.length).toBe(1);
    });
  });

  describe('GET /api/projects/:id', () => {
    let projectAId = '';

    beforeEach(async () => {
      const res = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Proj A' });
      projectAId = res.body.data.id;
    });

    it('Should retrieve owned project (200)', async () => {
      const res = await request(app)
        .get(`/api/projects/${projectAId}`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
      expect(res.body.data.id).toBe(projectAId);
    });

    it('Should return 404 if project doesnt exist', async () => {
      const res = await request(app)
        .get('/api/projects/some-fake-id')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(404);
    });

    it('Should return 404/403 if User B attempts to access User A project', async () => {
      const res = await request(app)
        .get(`/api/projects/${projectAId}`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect([403, 404]).toContain(res.status);
    });
  });

  describe('PUT /api/projects/:id', () => {
    let projectAId = '';

    beforeEach(async () => {
      const res = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Proj A' });
      projectAId = res.body.data.id;
    });

    it('Should update owned project (200)', async () => {
      const res = await request(app)
        .put(`/api/projects/${projectAId}`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Updated Proj A' });

      expect(res.status).toBe(200);
      expect(res.body.data.name).toBe('Updated Proj A');
    });

    it('Should fail validation on update (400)', async () => {
      const res = await request(app)
        .put(`/api/projects/${projectAId}`)
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: '' });

      expect(res.status).toBe(400);
    });

    it('Should return 404/403 when User B tries to update User A project', async () => {
      const res = await request(app)
        .put(`/api/projects/${projectAId}`)
        .set('Authorization', `Bearer ${tokenB}`)
        .send({ name: 'Hacked Proj' });

      expect([403, 404]).toContain(res.status);
    });
  });

  describe('DELETE /api/projects/:id', () => {
    let projectAId = '';

    beforeEach(async () => {
      const res = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Proj A To Delete' });
      projectAId = res.body.data.id;
    });

    it('Should delete owned project (200)', async () => {
      const res = await request(app)
        .delete(`/api/projects/${projectAId}`)
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
    });

    it('Should return 404/403 when User B tries to delete User A project', async () => {
      const res = await request(app)
        .delete(`/api/projects/${projectAId}`)
        .set('Authorization', `Bearer ${tokenB}`);

      expect([403, 404]).toContain(res.status);
    });

    it('Should verify cascade delete: tasks in deleted project are also removed', async () => {
      // First create a task in the project (even though /api/tasks might not exist, we can inject via prisma for this specific test)
      // Or we can assume /api/tasks exists for the test
      const task = await prisma.task.create({
        data: {
          name: 'Cascade Task',
          projectId: projectAId
        }
      });

      // Delete project
      const delRes = await request(app)
        .delete(`/api/projects/${projectAId}`)
        .set('Authorization', `Bearer ${tokenA}`);
      expect(delRes.status).toBe(200);

      // Verify task is gone
      const deletedTask = await prisma.task.findUnique({ where: { id: task.id } });
      expect(deletedTask).toBeNull();
    });
  });
});
