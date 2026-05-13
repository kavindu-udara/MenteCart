import { NextFunction, Request, Response } from "express";
import { z } from "zod";
import User from "../models/user.model";

const signupSchema = z.object({
    email: z.string().trim().email("Invalid email address"),
    password: z.string().min(6, "Password must be at least 6 characters long").regex(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$/, "Password must contain at least one letter and one number"),
});

export const signup = async (req: Request, res: Response, next: NextFunction) => {
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

    // TODO: hash password before saving to db
    

    // create new user
    const newUser = new User({ email, password });
    await newUser.save();

    res.status(201).json({
        message: "User registered successfully",
        user: {
            email,
        },
    });

};
