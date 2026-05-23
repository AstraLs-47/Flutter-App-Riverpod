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
      req.user = { id: 'user-1', role: 'user' };
      next();
    },
    authorize: (...roles) => (req, res, next) => next(),
  };
});

describe('Health Endpoints', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('GET /api/health - success', async () => {
    db.query.mockResolvedValueOnce({
      rows: [
        { id: '1', user_id: 'user-1', weight: 80.5, height: 180, bmi: 24.8, resting_heart_rate: 70, blood_pressure_systolic: 120, blood_pressure_diastolic: 80, blood_sugar: 90, measurement_date: '2026-05-23' }
      ]
    });

    const res = await request(app).get('/api/health');

    expect(res.statusCode).toBe(200);
    expect(res.body.length).toBe(1);
    expect(res.body[0].weight).toBe(80.5);
  });

  test('POST /api/health - success', async () => {
    db.query.mockResolvedValueOnce({
      rows: [
        { id: '1', user_id: 'user-1', weight: 82.0, height: 180, bmi: 25.3, resting_heart_rate: 72, blood_pressure_systolic: 122, blood_pressure_diastolic: 82, blood_sugar: 92, measurement_date: '2026-05-23' }
      ]
    });

    const res = await request(app)
      .post('/api/health')
      .send({
        weight: 82.0,
        height: 180,
        restingHeartRate: 72,
        bloodPressureSystolic: 122,
        bloodPressureDiastolic: 82,
        bloodSugar: 92,
        measurementDate: '2026-05-23'
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.weight).toBe(82.0);
  });
});
