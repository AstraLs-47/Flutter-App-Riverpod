const request = require('supertest');
const app = require('../src/server');
const db = require('../src/config/db');

jest.mock('../src/config/db', () => {
  return {
    query: jest.fn(),
    on: jest.fn(),
  };
});

describe('Products Endpoints', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('GET /api/products - success', async () => {
    db.query.mockResolvedValueOnce({
      rows: [
        { id: '1', name: 'Product A', description: 'Desc A', category: 'Cat A', image_url: 'imgA.png', is_active: true }
      ]
    });

    const res = await request(app).get('/api/products');

    expect(res.statusCode).toBe(200);
    expect(res.body.length).toBe(1);
    expect(res.body[0].name).toBe('Product A');
  });

  test('POST /api/products - success', async () => {
    db.query.mockResolvedValueOnce({
      rows: [
        { id: '1', name: 'New Product', description: 'New Desc', category: 'New Cat', image_url: 'newImg.png', is_active: true }
      ]
    });

    const res = await request(app)
      .post('/api/products')
      .send({
        name: 'New Product',
        description: 'New Desc',
        category: 'New Cat',
        imageUrl: 'newImg.png'
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.name).toBe('New Product');
  });
});
