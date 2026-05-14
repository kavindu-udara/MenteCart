import mongoose from "mongoose";

export interface IBooking {
  userId: mongoose.Types.ObjectId;
  status: "pending" | "confirmed" | "completed" | "cancelled" | "failed";
  paymentMethod: "payhere" | "cash" | "pay_on_arrival";
  paymentStatus: "pending" | "paid" | "failed";
  totalAmount: number;
  items: {
    serviceId: mongoose.Types.ObjectId;
    selectedDate: Date;
    timeSlotStart: string;
    timeSlotEnd: string;
    priceAtBooking: number;
  }[];
  statusHistory: {
    status: string;
    timestamp: Date;
    reason?: string;
  }[];
  cancelledAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const bookingSchema = new mongoose.Schema<IBooking>(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    status: {
      type: String,
      enum: ["pending", "confirmed", "completed", "cancelled", "failed"],
      default: "pending",
    },
    paymentMethod: {
      type: String,
      enum: ["payhere", "cash", "pay_on_arrival"],
      required: true,
    },
    paymentStatus: {
      type: String,
      enum: ["pending", "paid", "failed"],
      default: "pending",
    },
    totalAmount: { type: Number, required: true, min: 0 },
    items: [
      {
        serviceId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Service",
          required: true,
        },
        selectedDate: { type: Date, required: true },
        timeSlotStart: { type: String, required: true },
        timeSlotEnd: { type: String, required: true },
        priceAtBooking: { type: Number, required: true, min: 0 },
      },
    ],
    statusHistory: [
      {
        status: { type: String, required: true },
        timestamp: { type: Date, default: Date.now },
        reason: { type: String },
      },
    ],
    cancelledAt: { type: Date },
  },
  { timestamps: true },
);

const Booking = mongoose.model("Booking", bookingSchema);

export default Booking;
