import { errorMiddleware } from '../../src/middlewares/error.middleware';
import { AppError } from '../../src/utils/appError';
import { createMockNext, createMockResponse } from '../helpers/mockHttp';

describe('errorMiddleware', () => {
  it('serializes AppError responses', () => {
    const req = {} as any;
    const res = createMockResponse();
    const next = createMockNext();
    const error = new AppError(400, 'VALIDATION_ERROR', 'Invalid data');

    errorMiddleware(error, req, res, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({
      message: 'Invalid data',
      errorCode: 'VALIDATION_ERROR',
    });
  });

  it('returns a generic 500 for unknown errors', () => {
    const req = {} as any;
    const res = createMockResponse();
    const next = createMockNext();

    errorMiddleware(new Error('boom'), req, res, next);

    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith({ message: 'Internal server error' });
  });
});