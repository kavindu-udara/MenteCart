import { NextFunction, Request, Response } from "express";

type SignupRequest = {
    username: string;
    email: string;
    password: string;
};

export const signup = async (req : Request, res : Response, next : NextFunction) => {
    const { username, email, password } = req.body as SignupRequest;

    if (!username || !email || !password) {
        return res.status(400).json({ message: "All fields are required" });
    }

  res.send("Signup endpoint");
};
