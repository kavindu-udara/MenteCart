export interface PaymentInstructions {
    url :string | undefined;
    params: {
        merchant_id: string | undefined;
        return_url: string | undefined;
        cancel_url: string | undefined;
        notify_url: string | undefined;
        order_id: string;
        items: string;
        currency: string;
        amount: string;
        first_name: string;
        last_name: string;
        email: string;
        phone: string;
        address: string;
        city: string;
        country: string;
        hash: string;
    }
}
 