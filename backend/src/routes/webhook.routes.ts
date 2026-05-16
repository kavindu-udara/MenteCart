import express from 'express';
import { WebhookController } from '../controllers/webhook.controller';

const router = express.Router();
const webhookController = new WebhookController();

//  raw() MUST come BEFORE express.json()
router.post(
  '/payhere',
  express.raw({ type: 'application/x-www-form-urlencoded' }),
  webhookController.handlePayHereWebhook
);

export default router;
