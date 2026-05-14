import { NextFunction, Request, Response } from "express";
import { AppError } from "../utils/appError.js";

export const errorMiddleware = (
  err: unknown,
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (res.headersSent) {
    return next(err);
  }

  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      message: err.message,
      errorCode: err.errorCode,
    });
  }

  console.error("Unhandled error:", err);

  return res.status(500).json({
    message: "Internal server error",
  });
};