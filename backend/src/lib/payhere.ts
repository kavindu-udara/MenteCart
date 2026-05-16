import crypto from "crypto";

export const generatePayHereHash = (params: {
  merchant_id: string;
  order_id: string;
  amount: string;
  currency: string;
  secret: string;
}) => {
  const md5 = (str: string) =>
    crypto.createHash("md5").update(str).digest("hex").toUpperCase();
  const hashString =
    params.merchant_id +
    params.order_id +
    params.amount +
    params.currency +
    md5(params.secret);

  return md5(hashString);
};
