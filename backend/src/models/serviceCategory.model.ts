import mongoose from "mongoose";

const serviceCategorySchema = new mongoose.Schema(
  {
    name: { type: String, required: true, unique: true },
    description: { type: String, required: true },
  },
  { timestamps: true },
);

const ServiceCategory = mongoose.model(
  "ServiceCategory",
  serviceCategorySchema,
);

export default ServiceCategory;
