import mongoose, { Document } from "mongoose";

export interface IUser extends Document{
  firstName: string;
  lastName: string;
  email: string;
  role: "admin" | "user";
  password: string;
}

const userSchema = new mongoose.Schema<IUser>(
  {
    firstName: { type: String, required: true, length: 50 },
    lastName: { type: String, required: true, length: 50 },
    email: { type: String, required: true, unique: true, length: 100 },
    role: { type: String, enum: ["admin", "user"], default: "user" },
    password: { type: String, required: true },
  },
  { timestamps: true },
);

const User = mongoose.model("User", userSchema);

export default User;
