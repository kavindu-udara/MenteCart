import mongoose from "mongoose";
import { cartItemSchema } from "./cartItem.model";

export interface ICartItem {
    serviceId: mongoose.Types.ObjectId;
    selectedDate: Date;
    timeSlotStart: string;
    timeSlotEnd: string;
    quantity: number;
    priceAtAdd: number;
}

const cartSchema = new mongoose.Schema({
    userId : { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    items: [cartItemSchema],
    totalAmount: { type: Number, required: true, min: 0, default: 0 },
}, { timestamps: true });

const Cart = mongoose.model("Cart", cartSchema);

export default Cart;
