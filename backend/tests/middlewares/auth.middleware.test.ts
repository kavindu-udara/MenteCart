import { verifyUser } from '../../src/middlewares/auth.middleware';
import { AuthService } from '../../src/services/auth.service';
import { createMockNext, createMockResponse } from '../helpers/mockHttp';

describe('verifyUser middleware', () => {
  it('returns 401 when the cookie is missing', async () => {
    const req = { cookies: {} } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await verifyUser(req, res, next);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ message: 'Unauthorized' });
    expect(next).not.toHaveBeenCalled();
  });

  it('attaches decoded token data when the cookie is valid', async () => {
    const verifyJWT = jest
      .spyOn(AuthService.prototype, 'verifyJWT')
      .mockResolvedValue({ userId: 'user-1', email: 'user@example.com', role: 'user' });
    const req = { cookies: { access_token: 'token-123' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await verifyUser(req, res, next);

    expect(verifyJWT).toHaveBeenCalledWith('token-123');
    expect(req.decoded).toEqual({ userId: 'user-1', email: 'user@example.com', role: 'user' });
    expect(next).toHaveBeenCalledWith();
    expect(res.status).not.toHaveBeenCalled();
  });
});