import { WebhookController } from '../../src/controllers/webhook.controller';
import { BookingService } from '../../src/services/booking.service';
import { PayhereService } from '../../src/services/payhere.service';
import { createMockResponse } from '../helpers/mockHttp';

describe('WebhookController', () => {
  const controller = new WebhookController();

  it('rejects invalid PayHere signatures', async () => {
    jest.spyOn(PayhereService.prototype, 'verifyPayHereSignature').mockResolvedValue(false);
    const processSpy = jest.spyOn(BookingService.prototype, 'processPayHereWebhook');

    const req = {
      body: Buffer.from('merchant_id=m&order_id=o&payhere_amount=10.00&payhere_currency=USD&status_code=2&md5sig=bad'),
    } as any;
    const res = createMockResponse();

    await controller.handlePayHereWebhook(req, res);

    expect(processSpy).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.send).toHaveBeenCalledWith('Invalid signature');
  });

  it('processes valid PayHere webhooks', async () => {
    jest.spyOn(PayhereService.prototype, 'verifyPayHereSignature').mockResolvedValue(true);
    const processSpy = jest.spyOn(BookingService.prototype, 'processPayHereWebhook').mockResolvedValue({ _id: 'booking-1' } as any);

    const req = {
      body: Buffer.from('merchant_id=m&order_id=o&payhere_amount=10.00&payhere_currency=USD&status_code=2&md5sig=good'),
    } as any;
    const res = createMockResponse();

    await controller.handlePayHereWebhook(req, res);

    expect(processSpy).toHaveBeenCalledWith({
      merchant_id: 'm',
      order_id: 'o',
      payhere_amount: '10.00',
      payhere_currency: 'USD',
      status_code: '2',
      md5sig: 'good',
    });
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.send).toHaveBeenCalledWith('OK');
  });
});