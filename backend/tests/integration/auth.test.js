const request = require('supertest');
const app = require('../../src/app');
const prisma = require('../../src/utils/prisma');

describe('Auth Endpoints', () => {
  const testUser = {
    fullName: 'Test User',
    email: 'test@example.com',
    password: 'password123'
  };
  
  let authToken = '';

  beforeAll(async () => {
    // Make sure we connect just in case
    await prisma.$connect();
  });

  beforeEach(async () => {
    await prisma.task.deleteMany();
    await prisma.project.deleteMany();
    await prisma.user.deleteMany();
  });

  afterAll(async () => {
    await prisma.task.deleteMany();
    await prisma.project.deleteMany();
    await prisma.user.deleteMany();
    await prisma.$disconnect();
  });

  describe('POST /api/auth/register', () => {
    it('Should register a new user and return user + token (201)', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send(testUser);
      
      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user).toBeDefined();
      expect(res.body.data.token).toBeDefined();
      expect(res.body.data.user.email).toBe(testUser.email);
    });

    it('Should not return password in response', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send(testUser);
      
      expect(res.status).toBe(201);
      expect(res.body.data.user.password).toBeUndefined();
    });

    it('Should fail with duplicate email (409)', async () => {
      await request(app).post('/api/auth/register').send(testUser);
      
      const res = await request(app)
        .post('/api/auth/register')
        .send(testUser);
      
      expect(res.status).toBe(409);
    });

    it('Should fail with invalid email format (400)', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send({ ...testUser, email: 'invalid-email' });
      
      expect(res.status).toBe(400);
    });

    it('Should fail with short password (400)', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send({ ...testUser, password: 'short' });
      
      expect(res.status).toBe(400);
    });

    it('Should fail with missing required fields (400)', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send({ email: 'test@example.com' });
      
      expect(res.status).toBe(400);
    });
  });

  describe('POST /api/auth/login', () => {
    beforeEach(async () => {
      await request(app).post('/api/auth/register').send(testUser);
    });

    it('Should login with valid credentials and return token (200)', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ email: testUser.email, password: testUser.password });
      
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.token).toBeDefined();
    });

    it('Should fail with wrong password (401)', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ email: testUser.email, password: 'wrongpassword' });
      
      expect(res.status).toBe(401);
    });

    it('Should fail with non-existent email (401)', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ email: 'nonexistent@example.com', password: 'password123' });
      
      expect(res.status).toBe(401);
    });

    it('Should fail with invalid email format (400)', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ email: 'invalid', password: 'password123' });
      
      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/auth/me', () => {
    beforeEach(async () => {
      const res = await request(app).post('/api/auth/register').send(testUser);
      authToken = res.body.data.token;
    });

    it('Should return current user with valid token (200)', async () => {
      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user.email).toBe(testUser.email);
    });

    it('Should fail without token (401)', async () => {
      const res = await request(app)
        .get('/api/auth/me');
      
      expect(res.status).toBe(401);
    });

    it('Should fail with invalid token (401)', async () => {
      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer invalid-token`);
      
      expect(res.status).toBe(401);
    });
  });

  describe('POST /api/auth/logout', () => {
    beforeEach(async () => {
      const res = await request(app).post('/api/auth/register').send(testUser);
      authToken = res.body.data.token;
    });

    it('Should logout successfully with valid token (200)', async () => {
      const res = await request(app)
        .post('/api/auth/logout')
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
    });

    it('Should fail without token (401)', async () => {
      const res = await request(app)
        .post('/api/auth/logout');
      
      expect(res.status).toBe(401);
    });
  });
});
