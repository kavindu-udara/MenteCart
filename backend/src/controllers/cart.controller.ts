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

export const getUserCart = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = req.decoded.userId;

    // check cache first
    const cacheKey = `cart:${userId}`;
    const cachedData = await RedisService.get(cacheKey);

    // if cache hit, return cached data
    if (cachedData) {
      console.log("Cache hit for user cart");
      return res.status(200).json(JSON.parse(cachedData));
    }

    const cartItems = await CartItem.find({ userId }).populate<{
      serviceId: IService;
    }>("serviceId", "name description price");

    // calculate total price
    const totalPrice = cartItems.reduce((total, item) => {
      return total + item.serviceId.price * item.quantity;
    }, 0);

    // cache the result for 10 minutes
    await RedisService.set(
      cacheKey,
      JSON.stringify({
        cartItems,
        totalPrice,
        message: "Cart retrieved successfully",
      }),
      600,
    );

    res.status(200).json({
      cartItems,
      totalPrice,
      message: "Cart retrieved successfully",
    });
  } catch (error) {
    console.error("Get user cart error:", error);
    next(error);
  }
};

export const addItemToCart = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = req.decoded.userId;

    const result = addToCartSchema.safeParse(req.body);

    if (!result.success) {
      return res.status(400).json({
        message: "Validation failed",
        errors: result.error.flatten().fieldErrors,
      });
    }

    const { serviceId, quantity } = result.data;

    // check if item already exists in cart
    let cartItem = await CartItem.findOne({ userId, serviceId });

    if (cartItem) {
      // if item exists, update quantity
      cartItem.quantity += quantity;
      await cartItem.save();
    } else {
      // if item does not exist, create new cart item
      cartItem = new CartItem({ userId, serviceId, quantity });
      await cartItem.save();
    }

    // invalidate cache for user cart
    const cacheKey = `cart:${userId}`;
    await RedisService.del(cacheKey);

    res.status(200).json({
      message: "Item added to cart successfully",
      cartItem,
    });
  } catch (error) {
    console.error("Add item to cart error:", error);
    next(error);
  }
};
