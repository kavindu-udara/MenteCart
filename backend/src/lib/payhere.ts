import crypto from "crypto";

const md5Upper = (str: string): string =>
  crypto.createHash("md5").update(str).digest("hex").toUpperCase();

export function formatPayHereAmount(amount: number): string {
  return parseFloat(amount.toString())
    .toLocaleString("en-us", { minimumFractionDigits: 2 })
    .replaceAll(",", "");
}

// Generate hash
export function generatePayHereHash(params: {
  merchant_id: string;
  order_id: string;
  amount: number; 
  currency: "LKR" | "USD";
  secret: string;
}): string {
  const hashedSecret = md5Upper(params.secret);
  const amountFormatted = formatPayHereAmount(params.amount);

  const hashString =
    params.merchant_id +
    params.order_id +
    amountFormatted +
    params.currency +
    hashedSecret;

  return md5Upper(hashString);
}

// Verify webhook signature
export function verifyPayHereSignature(
  payload: {
    merchant_id: string;
    order_id: string;
    payhere_amount: string;
    payhere_currency: string;
    md5sig: string;
  },
  secret: string,
): boolean {
  const hashedSecret = md5Upper(secret);

  const hashString =
    payload.merchant_id +
    payload.order_id +
    payload.payhere_amount + 
    payload.payhere_currency +
    hashedSecret;

  const expected = md5Upper(hashString);
  return payload.md5sig === expected;
}
