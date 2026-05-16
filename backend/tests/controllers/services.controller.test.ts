import { ServicesController } from '../../src/controllers/services.controller';
import { RedisService } from '../../src/services/redis.service';
import { ServicesService } from '../../src/services/services.service';
import { createMockNext, createMockResponse } from '../helpers/mockHttp';

describe('ServicesController', () => {
  const controller = new ServicesController();

  it('returns cached services when available', async () => {
    jest.spyOn(RedisService, 'get').mockResolvedValue(JSON.stringify({ services: [], total: 0, hasMore: false, message: 'Services retrieved successfully' }));
    const serviceSpy = jest.spyOn(ServicesService.prototype, 'getAllServices');

    const req = { query: {} } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.getAllServices(req, res, next);

    expect(serviceSpy).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({ services: [], total: 0, hasMore: false, message: 'Services retrieved successfully' });
  });

  it('fetches services and caches the response on a cache miss', async () => {
    const serviceSpy = jest.spyOn(ServicesService.prototype, 'getAllServices').mockResolvedValue({
      services: [{ _id: 's1', title: 'Haircut' }],
      total: 1,
      hasMore: false,
    } as any);
    const cacheSetSpy = jest.spyOn(RedisService, 'set').mockResolvedValue(undefined as any);
    jest.spyOn(RedisService, 'get').mockResolvedValue(null);

    const req = { query: { page: '2', limit: '10', category: ' beauty ', search: ' trim ' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.getAllServices(req, res, next);

    expect(serviceSpy).toHaveBeenCalledWith(2, 10, 'beauty', 'trim');
    expect(cacheSetSpy).toHaveBeenCalledWith(
      'services:{"page":"2","limit":"10","category":" beauty ","search":" trim "}',
      JSON.stringify({
        services: [{ _id: 's1', title: 'Haircut' }],
        total: 1,
        hasMore: false,
        message: 'Services retrieved successfully',
      }),
      600,
    );
    expect(res.status).toHaveBeenCalledWith(200);
  });

  it('returns a service with generated slots when a date is provided', async () => {
    jest.spyOn(RedisService, 'get').mockResolvedValue(null);
    jest.spyOn(RedisService, 'set').mockResolvedValue(undefined as any);
    jest.spyOn(ServicesService.prototype, 'getServiceById').mockResolvedValue({
      _id: 'service-1',
      title: 'Haircut',
      toObject: () => ({ _id: 'service-1', title: 'Haircut' }),
    } as any);
    const slotsSpy = jest.spyOn(ServicesService.prototype, 'generateSlotsForDate').mockResolvedValue([
      { startTime: '09:00', endTime: '09:30', isAvailable: true, remainingCapacity: 2 },
    ] as any);

    const req = { params: { id: 'service-1' }, query: { date: '2026-05-16' } } as any;
    const res = createMockResponse();
    const next = createMockNext();

    await controller.getServiceById(req, res, next);

    expect(slotsSpy).toHaveBeenCalledWith(expect.objectContaining({ _id: 'service-1' }), '2026-05-16');
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({
      service: { _id: 'service-1', title: 'Haircut', slots: [{ startTime: '09:00', endTime: '09:30', isAvailable: true, remainingCapacity: 2 }] },
      message: 'Service retrieved successfully',
    });
  });
});