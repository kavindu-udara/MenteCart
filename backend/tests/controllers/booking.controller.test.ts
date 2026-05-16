import { BookingController } from '../../src/controllers/booking.controller';
import { CartController } from '../../src/controllers/cart.controller';
import { RedisService } from '../../src/services/redis.service';
import { BookingService } from '../../src/services/booking.service';
import { createMockNext, createMockResponse } from '../helpers/mockHttp';

describe('BookingController', () => {
  const controller = new BookingController();

  it('returns cached bookings when present', async () => {
    jest.spyOn(RedisService, 'get').mockResolvedValue(JSON.stringify({ bookings: [], message: 'Bookings retrieved successfully' }));
    const serviceSpy = jest.spyOn(BookingService.prototype, 'getBookingsByUser');

    const req = { decoded: { userId: 'user-1' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.getBookings(req, res, next);

    expect(serviceSpy).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({ bookings: [], message: 'Bookings retrieved successfully' });
  });

  it('creates a booking and clears the cart cache on checkout', async () => {
    jest.spyOn(RedisService, 'get').mockResolvedValue(null);
    const delSpy = jest.spyOn(RedisService, 'del').mockResolvedValue(undefined as any);
    const clearCacheSpy = jest.spyOn(CartController.prototype, 'clearCache').mockResolvedValue(undefined as any);
    jest.spyOn(BookingService.prototype, 'checkout').mockResolvedValue({ _id: 'booking-1' } as any);

    const req = { decoded: { userId: 'user-1' }, body: { paymentMethod: 'cash' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.checkout(req, res, next);

    expect(delSpy).toHaveBeenCalledWith('bookings:user-1');
    expect(clearCacheSpy).toHaveBeenCalledWith('user-1');
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({ booking: { _id: 'booking-1' }, message: 'Checkout successful' });
  });

  it('returns validation errors for invalid checkout bodies', async () => {
    const req = { decoded: { userId: 'user-1' }, body: { paymentMethod: 'card' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.checkout(req, res, next);

    expect(next).toHaveBeenCalled();
    const error = next.mock.calls[0][0];
    expect(error.statusCode).toBe(400);
    expect(error.errorCode).toBe('VALIDATION_ERROR');
  });

  it('returns a booking by id', async () => {
    jest.spyOn(RedisService, 'get').mockResolvedValue(null);
    jest.spyOn(RedisService, 'set').mockResolvedValue(undefined as any);
    jest.spyOn(BookingService.prototype, 'getBookingById').mockResolvedValue({ _id: 'booking-1' } as any);

    const req = { decoded: { userId: 'user-1' }, params: { bookingId: 'booking-1' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.getBookingById(req, res, next);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({ booking: { _id: 'booking-1' }, message: 'Booking retrieved successfully' });
  });

  it('cancels a booking', async () => {
    jest.spyOn(RedisService, 'del').mockResolvedValue(undefined as any);
    jest.spyOn(BookingService.prototype, 'cancelBooking').mockResolvedValue({ _id: 'booking-1', status: 'cancelled' } as any);

    const req = { decoded: { userId: 'user-1' }, params: { bookingId: 'booking-1' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.cancelBooking(req, res, next);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({
      booking: { _id: 'booking-1', status: 'cancelled' },
      message: 'Booking cancelled successfully',
    });
  });
});