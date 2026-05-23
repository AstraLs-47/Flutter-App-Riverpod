const request = require('supertest');
const app = require('../src/server');
const db = require('../src/config/db');

jest.mock('../src/config/db', () => {
  return {
    query: jest.fn(),
    on: jest.fn(),
  };
});

describe('Auth Endpoints', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('POST /api/auth/signup - success', async () => {
    db.query.mockResolvedValueOnce({ rows: [] })
            .mockResolvedValueOnce({
              rows: [{
                id: '1',
                email: 'test@example.com',
                password_hash: 'hashedpassword',
                first_name: 'John',
                last_name: 'Doe',
                role: 'user',
              }]
            });

    const res = await request(app)
      .post('/api/auth/signup')
      .send({
        email: 'test@example.com',
        password: 'password123',
        firstName: 'John',
        lastName: 'Doe'
      });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty('token');
    expect(res.body.user.email).toBe('test@example.com');
  });

  test('POST /api/auth/signin - success', async () => {
    const bcrypt = require('bcryptjs');
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash('password123', salt);

    db.query.mockResolvedValueOnce({
      rows: [{
        id: '1',
        email: 'test@example.com',
        password_hash: passwordHash,
        first_name: 'John',
        last_name: 'Doe',
        role: 'user',
      }]
    });

    const res = await request(app)
      .post('/api/auth/signin')
      .send({
        email: 'test@example.com',
        password: 'password123'
      });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('token');
  });
});
