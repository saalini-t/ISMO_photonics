const request = require('supertest');
const app = require('../../src/app');
const prisma = require('../../src/utils/prisma');

describe('Dashboard Endpoints', () => {
  const userA = {
    fullName: 'User A',
    email: 'dash-a@example.com',
    password: 'password123'
  };

  const userB = {
    fullName: 'User B',
    email: 'dash-b@example.com',
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

  describe('GET /api/dashboard', () => {
    it('Should return all 0 counts for user with no projects/tasks', async () => {
      const res = await request(app)
        .get('/api/dashboard')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(res.status).toBe(200);
      
      const stats = res.body.data;
      expect(stats).toBeDefined();
      expect(stats.totalProjects).toBe(0);
      expect(stats.totalTasks).toBe(0);
      
      // Checking structure depending on implementation, ensuring zeroes
      // It might group by status. Let's make sure values are all 0 or empty objects.
      if (stats.projectsByStatus) {
        Object.values(stats.projectsByStatus).forEach(val => expect(val).toBe(0));
      }
      if (stats.tasksByStatus) {
        Object.values(stats.tasksByStatus).forEach(val => expect(val).toBe(0));
      }
    });

    it('Should return accurate stats matching created data and not bleed between users', async () => {
      // User A creates 2 projects: 1 IN_PROGRESS, 1 COMPLETED
      const p1Res = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Proj 1' });
      
      const p2Res = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ name: 'Proj 2' });

      // Assuming we can update status
      await request(app).put(`/api/projects/${p1Res.body.data.id}`)
        .set('Authorization', `Bearer ${tokenA}`).send({ status: 'IN_PROGRESS' });
      await request(app).put(`/api/projects/${p2Res.body.data.id}`)
        .set('Authorization', `Bearer ${tokenA}`).send({ status: 'COMPLETED' });

      // User A creates tasks: 2 PENDING, 1 COMPLETED
      await request(app).post('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ title: 'Task 1', name: 'Task 1', projectId: p1Res.body.data.id }); // default PENDING
      await request(app).post('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ title: 'Task 2', name: 'Task 2', projectId: p1Res.body.data.id }); // default PENDING
      const t3Res = await request(app).post('/api/tasks')
        .set('Authorization', `Bearer ${tokenA}`)
        .send({ title: 'Task 3', name: 'Task 3', projectId: p2Res.body.data.id });
      await request(app).put(`/api/tasks/${t3Res.body.data.id}`)
        .set('Authorization', `Bearer ${tokenA}`).send({ status: 'COMPLETED' });

      // User B creates data to test bleeding
      const pbRes = await request(app)
        .post('/api/projects')
        .set('Authorization', `Bearer ${tokenB}`)
        .send({ name: 'Proj B' });
      await request(app).post('/api/tasks')
        .set('Authorization', `Bearer ${tokenB}`)
        .send({ title: 'Task B1', name: 'Task B1', projectId: pbRes.body.data.id });

      // Fetch dashboard for User A
      const resA = await request(app)
        .get('/api/dashboard')
        .set('Authorization', `Bearer ${tokenA}`);

      expect(resA.status).toBe(200);
      
      const statsA = resA.body.data;
      expect(statsA.totalProjects).toBe(2);
      expect(statsA.totalTasks).toBe(3);
      
      // Optional check for breakdown if they return it. 
      // But minimum, we verify total counts are exactly User A's
      if (statsA.projectsByStatus) {
        expect(statsA.projectsByStatus.IN_PROGRESS).toBe(1);
        expect(statsA.projectsByStatus.COMPLETED).toBe(1);
      }

      // Fetch dashboard for User B
      const resB = await request(app)
        .get('/api/dashboard')
        .set('Authorization', `Bearer ${tokenB}`);

      expect(resB.status).toBe(200);
      
      const statsB = resB.body.data;
      expect(statsB.totalProjects).toBe(1);
      expect(statsB.totalTasks).toBe(1);
    });
  });
});
