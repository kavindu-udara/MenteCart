import request from 'supertest';
import app from '../../src/app';

describe('app routes', () => {
  it('responds to GET /', async () => {
    const response = await request(app).get('/').expect(200);

    expect(response.body).toEqual({ message: 'Hello World' });
  });

  it('responds to GET /test', async () => {
    const response = await request(app).get('/test').expect(200);

    expect(response.text).toBe('Hello, MenteCart!');
  });

  it('returns 404 for unknown routes', async () => {
    const response = await request(app).get('/missing-route').expect(404);

    expect(response.body).toEqual({ message: 'Route not found' });
  });
});