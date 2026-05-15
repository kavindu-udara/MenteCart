import { IUser } from "../models/user.model";

const md5 = require("md5"); 

export class PayhereService {
  private merchantId: string = process.env.PAYHERE_MERCHANT_ID || "";
  private merchantSecret: string = process.env.PAYHERE_MERCHANT_SECRET || "";
  private sandboxUrl: string = process.env.PAYHERE_SANDBOX_URL || "";
  private productionUrl: string = process.env.PAYHERE_PRODUCTION_URL || "";
  //
  private returnUrl: string =
    process.env.PAYHERE_RETURN_URL || "http://localhost:3000/payment/success";
  private cancelUrl: string =
    process.env.PAYHERE_CANCEL_URL || "http://localhost:3000/payment/cancel";
  private notifyUrl: string =
    process.env.PAYHERE_NOTIFY_URL || "http://localhost:3000/payment/notify";

  private isSandbox: boolean = process.env.PAYHERE_IS_SANDBOX === "true";

  private CURRENCY = "USD";

  async createPaymentLink(
    user: IUser,
    phone: string,
    address: string,
    city: string,
    country: string,
    order_id: string,
    items: string,
    amount: number,
  ): Promise<string> {
    const url = this.isSandbox ? this.sandboxUrl : this.productionUrl;

    const params = new URLSearchParams({
      merchant_id: this.merchantId,
      return_url: this.returnUrl,
      cancel_url: this.cancelUrl,
      notify_url: this.notifyUrl,
      first_name: user.firstName,
      last_name: user.lastName,
      email: user.email,
      phone,
      address,
      city,
      country,
      order_id,
      items,
      amount: amount.toFixed(2),
      currency: this.CURRENCY,
      hash: this.generateHash(order_id, amount),
    });

    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: params.toString(),
    });

    if (!response.ok) {
      throw new Error(`Failed to create payment link: ${response.statusText}`);
    }

    const responseData = await response.json();

    console.log("Payhere response data:", responseData);
    return responseData.payment_url;
  }

  private generateHash(orderId: string, amountFormated: number): string {
    const hashedSecret = md5(this.merchantSecret).toString().toUpperCase();
    const hash = md5(
      this.merchantId + orderId + amountFormated + this.CURRENCY + hashedSecret,
    )
      .toString()
      .toUpperCase();

    return hash;
  }
}
