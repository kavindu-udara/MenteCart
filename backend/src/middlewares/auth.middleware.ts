import { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";

export const verifyUser = (req: Request, res: Response, next: NextFunction) => {
  try {
    const token = req.cookies.access_token;
    if (!token) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    req.decoded = jwt.verify(token, process.env.JWT_SECRET as string) as { userId: string; email: string };
    
    next();
    
  } catch (error) {
    console.error("Authentication error:", error);
    res.status(401).json({ message: "Unauthorized" });
  }
};
