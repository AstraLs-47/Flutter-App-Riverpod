const request = require('supertest');
const app = require('../src/server');
const db = require('../src/config/db');

jest.mock('../src/config/db', () => {
  return {
    query: jest.fn(),
    on: jest.fn(),
  };
});

jest.mock('../src/middleware/auth', () => {
  return {
    auth: (req, res, next) => {
      req.user = { id: 'admin-1', role: 'admin' };
      next();
    },
    authorize: (...roles) => (req, res, next) => next(),
  };
});

describe('Admin Endpoints', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('GET /api/admin/dashboard - success', async () => {
    // Mock the queries inside getDashboard: users count, exercises count, products count, announcements count, etc.
    db.query
      .mockResolvedValueOnce({ rows: [{ count: '10' }] }) // users count
      .mockResolvedValueOnce({ rows: [{ count: '5' }] })  // exercises count
      .mockResolvedValueOnce({ rows: [{ count: '8' }] })  // products count
      .mockResolvedValueOnce({ rows: [{ count: '3' }] })  // announcements count
      .mockResolvedValueOnce({ rows: [] })                 // category distribution
      .mockResolvedValueOnce({ rows: [] })                 // product category distribution
      .mockResolvedValueOnce({ rows: [] })                 // engagement data
      .mockResolvedValueOnce({ rows: [] });                // recent activities

    const res = await request(app).get('/api/admin/dashboard');

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('totalUsers');
    expect(res.body).toHaveProperty('totalExercises');
    expect(res.body).toHaveProperty('totalProducts');
  });
});
