import { NextFunction, Request, Response } from "express";
import { addToCartSchema } from "../lib/zodSchemas";
import { CartService } from "../services/cart.service";
import { AppError, ErrorCode } from "../utils/appError";

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

  async updateItem(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.decoded.userId;
      const itemId = req.params.itemId;
      const { selectedDate, timeSlotStart, timeSlotEnd } = req.body;

      if (!selectedDate || !timeSlotStart || !timeSlotEnd) {
        return next(
          new AppError(
            400,
            ErrorCode.VALIDATION_ERROR,
            "selectedDate, timeSlotStart and timeSlotEnd are required",
          ),
        );
      }

      // if itemId type is not string, return validation error
      if (typeof itemId !== "string") {
        return next(
          new AppError(
            400,
            ErrorCode.VALIDATION_ERROR,
            "itemId must be a string",
          ),
        );
      }

      const cart = await cartService.updateItem(
        userId,
        itemId,
        selectedDate,
        timeSlotStart,
        timeSlotEnd,
      );

      res.status(200).json({
        message: "Cart item updated successfully",
        cart,
      });
    } catch (error) {
      console.error("Update cart item error:", error);
      next(error);
    }
  }

  async removeItem(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.decoded.userId;
      const itemId = req.params.itemId;

      // if itemId type is not string, return validation error
      if (typeof itemId !== "string") {
        return next(
          new AppError(
            400,
            ErrorCode.VALIDATION_ERROR,
            "itemId must be a string",
          ),
        );
      }

      const cart = await cartService.removeItem(userId, itemId);

      res.status(200).json({
        message: "Cart item removed successfully",
        cart,
      });
    } catch (error) {
      console.error("Remove cart item error:", error);
      next(error);
    }
  }

}
