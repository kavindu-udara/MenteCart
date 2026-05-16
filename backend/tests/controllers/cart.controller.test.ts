import { CartController } from '../../src/controllers/cart.controller';
import { RedisService } from '../../src/services/redis.service';
import { CartService } from '../../src/services/cart.service';
import { createMockNext, createMockResponse } from '../helpers/mockHttp';

describe('CartController', () => {
  const controller = new CartController();

  it('returns cached cart data when present', async () => {
    jest.spyOn(RedisService, 'get').mockResolvedValue(JSON.stringify({ cart: { items: [] }, message: 'Cart retrieved successfully' }));
    const serviceSpy = jest.spyOn(CartService.prototype, 'getCart');

    const req = { decoded: { userId: 'user-1' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.getCart(req, res, next);

    expect(serviceSpy).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({ cart: { items: [] }, message: 'Cart retrieved successfully' });
  });

  it('adds an item to the cart and clears cache', async () => {
    jest.spyOn(RedisService, 'get').mockResolvedValue(null);
    const delSpy = jest.spyOn(RedisService, 'del').mockResolvedValue(undefined as any);
    jest.spyOn(CartService.prototype, 'addItem').mockResolvedValue({ items: [{ serviceId: 'service-1' }] } as any);

    const req = {
      decoded: { userId: 'user-1' },
      body: {
        serviceId: '0123456789abcdef01234567',
        selectedDate: '2026-05-16',
        timeSlotStart: '09:00',
        timeSlotEnd: '09:30',
      },
    } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.addItem(req, res, next);

    expect(delSpy).toHaveBeenCalledWith('cart:user-1');
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({
      message: 'Item added to cart successfully',
      cart: { items: [{ serviceId: 'service-1' }] },
    });
  });

  it('rejects invalid update payloads', async () => {
    const req = {
      decoded: { userId: 'user-1' },
      params: { itemId: 'item-1' },
      body: { timeSlotStart: '09:00' },
    } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.updateItem(req, res, next);

    expect(next).toHaveBeenCalled();
    const error = next.mock.calls[0][0];
    expect(error.statusCode).toBe(400);
    expect(error.message).toBe('selectedDate, timeSlotStart and timeSlotEnd are required');
  });

  it('removes an item and invalidates cart cache', async () => {
    const delSpy = jest.spyOn(RedisService, 'del').mockResolvedValue(undefined as any);
    jest.spyOn(CartService.prototype, 'removeItem').mockResolvedValue({ items: [] } as any);

    const req = { decoded: { userId: 'user-1' }, params: { itemId: 'item-1' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.removeItem(req, res, next);

    expect(delSpy).toHaveBeenCalledWith('cart:user-1');
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({
      message: 'Cart item removed successfully',
      cart: { items: [] },
    });
  });
});