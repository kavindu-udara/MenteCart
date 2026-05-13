import { NextFunction, Request, Response } from "express";
import User from "../models/user.model";
import bcrypt from "bcryptjs";
import { loginSchema, signupSchema } from "../lib/zodSchemas";
import jwt from "jsonwebtoken";

export const signup = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const result = signupSchema.safeParse(req.body);

    if (!result.success) {
      return res.status(400).json({
        message: "Validation failed",
        errors: result.error.flatten().fieldErrors,
      });
    }

    const { email, password } = result.data;

    // find user in db
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(409).json({ message: "Email already in use" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // create new user
    const newUser = new User({ email, password: hashedPassword });
    await newUser.save();

    res.status(201).json({
      message: "User registered successfully",
      user: {
        email,
      },
    });
  } catch (error) {
    console.error("Signup error:", error);
    next(error);
  }
};

export const login = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const result = loginSchema.safeParse(req.body);

    if (!result.success) {
      return res.status(400).json({
        message: "Validation failed",
        errors: result.error.flatten().fieldErrors,
      });
    }

    const { email, password } = result.data;

    // find user in db
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // compare password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // generate JWT token
    const token = jwt.sign(
      { userId: user._id, email: user.email },
      process.env.JWT_SECRET || "jwt_secret",
      { expiresIn: "24h" },
    );

    // set token in httpOnly cookie
    res
      .cookie("access_token", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "strict",
        maxAge: 24 * 60 * 60 * 1000, // 24 hours
      })
      .status(200)
      .json({ message: "Login successful" });
  } catch (error) {
    console.error("Login error:", error);
    next(error);
  }
};

export const me = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.decoded) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    const user = await User.findById(req.decoded.userId).select("-password");
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({ user });
  } catch (error) {
    console.error("Me error:", error);
    next(error);
  }
};
