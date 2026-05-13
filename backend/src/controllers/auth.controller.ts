import { NextFunction, Request, Response } from "express";
import { z } from "zod";

const signupSchema = z.object({
    username: z.string().trim().min(1, "Username is required"),
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

    const { username, email, password } = result.data;

    res.send(`Signup endpoint for ${username}`);
};
