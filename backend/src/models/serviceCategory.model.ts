import mongoose from "mongoose";

export interface IServiceCategory {
  name: string;
  description: string;
}

const serviceCategorySchema = new mongoose.Schema<IServiceCategory>(
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
