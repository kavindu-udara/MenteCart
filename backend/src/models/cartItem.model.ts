import mongoose from "mongoose";

export const cartItemSchema = new mongoose.Schema(
  {
    serviceId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Service",
      required: true,
    },
    selectedDate: { type: Date, required: true },
    timeSlotStart: { type: String, required: true },
    timeSlotEnd: { type: String, required: true },
    quantity: { type: Number, required: true, min: 1, default: 1 },
    priceAtAdd: { type: Number, required: true, min: 0 },
  },
  { timestamps: true },
);

const CartItem = mongoose.model("CartItem", cartItemSchema);

export default CartItem;
