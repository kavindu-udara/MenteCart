import { Request } from 'express';

declare global {
  namespace Express {
    interface Request {
      decoded?: { userId: string; email: string };
    }
  }
}
