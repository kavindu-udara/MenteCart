import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true, length: 50 },
  email: { type: String, required: true, unique: true, length: 100 },
  role: { type: String, enum: ["admin", "user"], default: "user" },
  password: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

const User = mongoose.model("User", userSchema);

export default User;
