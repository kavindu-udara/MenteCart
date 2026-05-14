import mongoose, { Schema } from "mongoose";

const SlotCapacitySchema = new Schema(
  {
    serviceId: { type: Schema.Types.ObjectId, ref: "Service", required: true },
    date: { type: Date, required: true },
    timeSlotStart: { type: String, required: true },
    timeSlotEnd: { type: String, required: true },
    maxCapacity: { type: Number, required: true },
    bookedCount: { type: Number, default: 0 },
  },
  { timestamps: true },
);

// Unique index per service+date+slot
SlotCapacitySchema.index(
  { serviceId: 1, date: 1, timeSlotStart: 1, timeSlotEnd: 1 },
  { unique: true },
);

export const SlotCapacity = mongoose.model("SlotCapacity", SlotCapacitySchema);
