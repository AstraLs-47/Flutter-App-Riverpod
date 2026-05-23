const request = require('supertest');
const app = require('../src/server');
const db = require('../src/config/db');

jest.mock('../src/config/db', () => {
  return {
    query: jest.fn(),
    on: jest.fn(),
  };
});

describe('Announcements Endpoints', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('GET /api/announcements - success', async () => {
    db.query.mockResolvedValueOnce({
      rows: [
        { id: '1', title: 'Gym Maintenance', description: 'Gym closed on Monday', date: '2026-05-23' }
      ]
    });

    const res = await request(app).get('/api/announcements');

    expect(res.statusCode).toBe(200);
    expect(res.body.length).toBe(1);
    expect(res.body[0].title).toBe('Gym Maintenance');
  });

  test('POST /api/announcements - success', async () => {
    db.query.mockResolvedValueOnce({
      rows: [
        { id: '1', title: 'New Class', description: 'Pilates starting soon', date: '2026-05-23' }
      ]
    });

    const res = await request(app)
      .post('/api/announcements')
      .send({
        title: 'New Class',
        description: 'Pilates starting soon',
        date: '2026-05-23'
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.title).toBe('New Class');
  });
});
