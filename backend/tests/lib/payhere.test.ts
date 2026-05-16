import crypto from 'crypto';
import { formatPayHereAmount, generatePayHereHash, verifyPayHereSignature } from '../../src/lib/payhere';

describe('payhere helpers', () => {
  it('formats amounts with two decimals', () => {
    expect(formatPayHereAmount(1250)).toBe('1250.00');
    expect(formatPayHereAmount(1250.5)).toBe('1250.50');
  });

  it('generates a deterministic hash', () => {
    const params = {
      merchant_id: 'M123',
      order_id: 'ORDER-1',
      amount: 1500,
      currency: 'USD' as const,
      secret: 'secret123',
    };

    const expected = crypto
      .createHash('md5')
      .update(
        `${params.merchant_id}${params.order_id}1500.00${params.currency}${crypto
          .createHash('md5')
          .update(params.secret)
          .digest('hex')
          .toUpperCase()}`,
      )
      .digest('hex')
      .toUpperCase();

    expect(generatePayHereHash(params)).toBe(expected);
  });

  it('verifies matching webhook signatures', () => {
    const secret = 'secret123';
    const payload = {
      merchant_id: 'M123',
      order_id: 'ORDER-1',
      payhere_amount: '1500.00',
      payhere_currency: 'USD',
      md5sig: generatePayHereHash({
        merchant_id: 'M123',
        order_id: 'ORDER-1',
        amount: 1500,
        currency: 'USD',
        secret,
      }),
    };

    expect(verifyPayHereSignature(payload, secret)).toBe(true);
    expect(verifyPayHereSignature({ ...payload, md5sig: 'bad' }, secret)).toBe(false);
  });
});