import { Request, Response } from 'express';
import { BookingService } from '../services/booking.service';
import { PayhereService } from '../services/payhere.service';

const payhereService = new PayhereService();

export class WebhookController {
  async handlePayHereWebhook(req: Request, res: Response) {
    try {
      // Parse raw form data
      const rawBody = req.body.toString();
      const params = new URLSearchParams(rawBody);
      
      const payload = {
        merchant_id: params.get('merchant_id')!,
        order_id: params.get('order_id')!,
        payhere_amount: params.get('payhere_amount')!,
        payhere_currency: params.get('payhere_currency')!,
        status_code: params.get('status_code')!, // '2' = success
        md5sig: params.get('md5sig')!
      };

      const isValid = await payhereService.verifyPayHereSignature(
        payload, 
        process.env.PAYHERE_MERCHANT_SECRET!
      );
      if (!isValid) {
        console.error('[PayHere] Invalid signature');
        return res.status(400).send('Invalid signature');
      }

      const bookingService = new BookingService();
      await bookingService.processPayHereWebhook(payload);

      res.status(200).send('OK');
    } catch (err) {
      console.error('[PayHere Webhook Error]', err);
      res.status(500).send('Internal error');
    }
  }
}