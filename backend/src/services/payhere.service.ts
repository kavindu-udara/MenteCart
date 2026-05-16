import { generatePayHereHash } from "../lib/payhere";

export class PayhereService {
  async verifyPayHereSignature(
    payload: Record<string, string>,
    secret: string,
  ): Promise<boolean> {
    const expected = generatePayHereHash({
      merchant_id: payload.merchant_id,
      order_id: payload.order_id,
      amount: payload.payhere_amount,
      currency: payload.payhere_currency,
      secret,
    });

    return payload.md5sig === expected;
  }
}
