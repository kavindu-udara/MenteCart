import mongoose, { Document } from "mongoose";

export interface IUser extends Document{
  email: string;
  role: "admin" | "user";
  password: string;
}

const userSchema = new mongoose.Schema<IUser>(
  {
    email: { type: String, required: true, unique: true, length: 100 },
    role: { type: String, enum: ["admin", "user"], default: "user" },
    password: { type: String, required: true },
  },
  { timestamps: true },
);

const User = mongoose.model("User", userSchema);

export default User;
