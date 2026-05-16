import { AuthController } from '../../src/controllers/auth.controller';
import { AuthService } from '../../src/services/auth.service';
import { createMockNext, createMockResponse } from '../helpers/mockHttp';

describe('AuthController', () => {
  const controller = new AuthController();

  it('returns validation errors for invalid signup payloads', async () => {
    const req = { body: { email: 'not-an-email' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.signup(req, res, next);

    expect(next).toHaveBeenCalled();
    const error = next.mock.calls[0][0];
    expect(error.statusCode).toBe(400);
    expect(error.errorCode).toBe('VALIDATION_ERROR');
  });

  it('registers a new user on valid signup', async () => {
    jest.spyOn(AuthService.prototype, 'register').mockResolvedValue({
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane@example.com',
      role: 'user',
    } as any);

    const req = {
      body: {
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        password: 'Passw0rd!',
      },
    } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.signup(req, res, next);

    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith({
      message: 'User registered successfully',
      user: {
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        role: 'user',
      },
    });
  });

  it('returns validation errors for invalid login payloads', async () => {
    const req = { body: { email: 'user@example.com' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.login(req, res, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({
      message: 'Validation failed',
      errors: {
        password: ['Invalid input: expected string, received undefined'],
      },
    });
  });

  it('sets the auth cookie after a successful login', async () => {
    jest.spyOn(AuthService.prototype, 'login').mockResolvedValue('jwt-token');

    const req = { body: { email: 'user@example.com', password: 'Passw0rd!' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.login(req, res, next);

    expect(res.cookie).toHaveBeenCalledWith(
      'access_token',
      'jwt-token',
      expect.objectContaining({
        httpOnly: true,
        sameSite: 'strict',
        maxAge: 24 * 60 * 60 * 1000,
      }),
    );
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({ message: 'Login successful' });
  });

  it('returns the current user when decoded data is present', async () => {
    jest.spyOn(AuthService.prototype, 'getUserByEmail').mockResolvedValue({
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane@example.com',
      role: 'user',
    } as any);

    const req = { decoded: { userId: 'u1', email: 'jane@example.com' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.me(req, res, next);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({
      user: {
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        role: 'user',
      },
      message: 'User retrieved successfully',
    });
  });
});