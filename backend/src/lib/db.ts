import mongoose from "mongoose";

export class DB {
  private static MONGO_URI: string = process.env.MONGO_URI || "mongodb://localhost:27017/mentecart";
  
  static async connect() {
    try {
      await mongoose.connect(this.MONGO_URI);
      console.log("MongoDB connected successfully");
    } catch (error) {
      console.error("MongoDB connection error:", error);
      process.exit(1);
    }
  }
}
