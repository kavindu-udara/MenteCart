import mongoose from "mongoose";

export class DB {
  static async connect() {
    try {
      const mongoUri = process.env.MONGO_URI || "mongodb://localhost:27017/mentecart";
      await mongoose.connect(mongoUri);
      console.log("MongoDB connected successfully");
    } catch (error) {
      console.error("MongoDB connection error:", error);
      process.exit(1);
    }
  }
}
