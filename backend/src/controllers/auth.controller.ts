import { NextFunction, Request, Response } from "express";

export const signup = async (req : Request, res : Response, next : NextFunction) => {
  res.send("Signup endpoint");
};
