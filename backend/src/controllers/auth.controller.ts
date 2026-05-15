import { NextFunction, Request, Response } from "express";
import { loginSchema, signupSchema } from "../lib/zodSchemas";
import { AuthService } from "../services/auth.service";
import { AppError, ErrorCode } from "../utils/appError";

const authService = new AuthService();

export class AuthController {
  async signup(req: Request, res: Response, next: NextFunction) {
    try {
      const result = signupSchema.safeParse(req.body);

      if (!result.success) {
        return next(
          new AppError(
            400,
            ErrorCode.VALIDATION_ERROR,
            JSON.stringify(result.error.flatten().fieldErrors),
          ),
        );
      }

      const { firstName, lastName, email, password } = result.data;

      const newUser = await authService.register(firstName, lastName, email, password, "user");

      res.status(201).json({
        message: "User registered successfully",
        user: {
          firstName: newUser.firstName,
          lastName: newUser.lastName,
          email: newUser.email,
          role: newUser.role,
        },
      });
    } catch (error) {
      console.error("Signup error:", error);
      next(error);
    }
  }

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const result = loginSchema.safeParse(req.body);
      if (!result.success) {
        return res.status(400).json({
          message: "Validation failed",
          errors: result.error.flatten().fieldErrors,
        });
      }

      const { email, password } = result.data;

      const token = await authService.login(email, password);

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
  }

  async me(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.decoded) {
        return res.status(401).json({ message: "Unauthorized" });
      }

      const user = await authService.getUserByEmail(req.decoded.email);
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }

      res
        .status(200)
        .json({
          user: { email: user.email, role: user.role },
          message: "User retrieved successfully",
        });
    } catch (error) {
      console.error("Me error:", error);
      next(error);
    }
  }
}
