import mongoose from "mongoose";
import { cartItemSchema, ICartItem } from "./cartItem.model";

export interface ICart {
    userId: mongoose.Types.ObjectId;
    items: ICartItem[];
    totalAmount: number;
}

const cartSchema = new mongoose.Schema({
    userId : { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    items: [cartItemSchema],
    totalAmount: { type: Number, required: true, min: 0, default: 0 },
}, { timestamps: true });

const Cart = mongoose.model("Cart", cartSchema);

export default Cart;
