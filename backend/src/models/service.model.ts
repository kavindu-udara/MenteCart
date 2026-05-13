import mongoose from "mongoose";

export interface IService {
  title: string;
  description: string;
  price: number;
  duration: number; // in minutes
  categoryId: mongoose.Types.ObjectId;
  imageUrl: string;
  capacityPerSlot: number;
}

const serviceSchema = new mongoose.Schema<IService>(
  {
    title: { type: String, required: true },
    description: { type: String, required: true },
    price: { type: Number, required: true, min: 0 },
    duration: { type: Number, required: true, min: 15 },
    categoryId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "ServiceCategory",
      required: true,
    },
    imageUrl: { type: String, required: true },
    capacityPerSlot: { type: Number, required: true, default: 1, min: 1 },
  },
  { timestamps: true },
);

const Service = mongoose.model("Service", serviceSchema);

export default Service;
