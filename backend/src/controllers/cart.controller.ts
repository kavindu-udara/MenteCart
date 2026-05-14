import { NextFunction, Request, Response } from "express";
import CartItem from "../models/cartItem.model";
import { IService } from "../models/service.model";
import { addToCartSchema } from "../lib/zodSchemas";
import { CartService } from "../services/cart.service";
import { AppError, ErrorCode } from "../utils/appError";
import { RedisService } from "../services/redis.service";

const cartService = new CartService();

export class CartController {
  async getCart(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.decoded.userId;
      const cart = await cartService.getCart(userId);
      res.status(200).json({ cart, message: "Cart retrieved successfully" });
    } catch (error) {
      next(error);
    }
  }

  async addItem(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.decoded.userId;
      const result = addToCartSchema.safeParse(req.body);

      if (!result.success) {
        const errors = result.error.flatten().fieldErrors;
        return next(
          new AppError(400, ErrorCode.VALIDATION_ERROR, JSON.stringify(errors)),
        );
      }

      const { serviceId, selectedDate, timeSlotStart, timeSlotEnd } =
        result.data;

      const cart = await cartService.addItem(
        userId,
        serviceId,
        selectedDate,
        timeSlotStart,
        timeSlotEnd,
      );

      res.status(200).json({
        message: "Item added to cart successfully",
        cart,
      });
    } catch (error) {
      console.error("Add item to cart error:", error);
      next(error);
    }
  }
}
