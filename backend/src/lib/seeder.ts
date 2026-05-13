import dotenv from "dotenv";
import { connectDB } from "./db";
import ServiceCategory from "../models/serviceCategory.model";
import Service from "../models/service.model";

dotenv.config();

const services = [
  {
    title: "Home Cleaning",
    description:
      "Professional home cleaning for apartments, houses, and offices.",
    price: 80,
    duration: 120,
    category: "Cleaning",
    imageUrl:
      "https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=1200&q=80",
    capacityPerSlot: 1,
  },
  {
    title: "Plumbing",
    description:
      "Quick plumbing repairs, leak fixes, and pipe maintenance services.",
    price: 95,
    duration: 90,
    category: "Home Services",
    imageUrl:
      "https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=1200&q=80",
    capacityPerSlot: 1,
  },
  {
    title: "Tutoring",
    description:
      "One-on-one tutoring sessions for math, science, and language support.",
    price: 45,
    duration: 60,
    category: "Education",
    imageUrl:
      "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?auto=format&fit=crop&w=1200&q=80",
    capacityPerSlot: 1,
  },
  {
    title: "Beauty Appointment",
    description:
      "Salon-style beauty appointments for hair, makeup, and skincare.",
    price: 70,
    duration: 75,
    category: "Beauty",
    imageUrl:
      "https://images.unsplash.com/photo-1522336572468-97b06e8ef143?auto=format&fit=crop&w=1200&q=80",
    capacityPerSlot: 1,
  },
];

const categories = [
  {
    name: "Cleaning",
    description: "Cleaning and housekeeping related services.",
  },
  {
    name: "Home Services",
    description: "Repairs and maintenance services for the home.",
  },
  {
    name: "Education",
    description: "Tutoring and educational support services.",
  },
  {
    name: "Beauty",
    description: "Beauty, grooming, and personal care services.",
  },
];

const seedServices = async () => {
  try {
    await connectDB();

    await ServiceCategory.deleteMany({});
    const createdCategories = await ServiceCategory.insertMany(categories);
    const categoryMap = new Map(
      createdCategories.map((category) => [category.name, category._id]),
    );

    await Service.deleteMany({});
    await Service.insertMany(
      services.map((service) => ({
        ...service,
        categoryId: categoryMap.get(service.category),
      })),
    );

    console.log(`Seeded ${services.length} services successfully.`);
    process.exit(0);
  } catch (error) {
    console.error("Service seeder error:", error);
    process.exit(1);
  }
};

seedServices();
