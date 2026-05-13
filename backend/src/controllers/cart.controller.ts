import { Request, Response } from "express";
import createRedisClient from "../lib/redis";
import CartItem from "../models/cartItem.model";
import { IService } from "../models/service.model";
import { addToCartSchema } from "../lib/zodSchemas";

const redisClient = await createRedisClient();

export const getUserCart = async (req : Request, res : Response) => {
  try {
    const userId = req.decoded.userId;

    // check cache first
    const cacheKey = `cart:${userId}`;
    const cachedData = await redisClient.get(cacheKey);

    // if cache hit, return cached data
    if (cachedData) {
      console.log("Cache hit for user cart");
      return res.status(200).json(JSON.parse(cachedData));
    }

    const cartItems = await CartItem.find({ userId }).populate<{serviceId : IService}>(
      "serviceId",
      "name description price",
    );

    // calculate total price
    const totalPrice = cartItems.reduce((total, item) => {
      return total + item.serviceId.price * item.quantity;
    }, 0);

    // cache the result for 10 minutes
    await redisClient.setEx(
      cacheKey,
      600,
      JSON.stringify({
        cartItems,
        totalPrice,
        message: "Cart retrieved successfully",
      }),
    );

    res.status(200).json({
      cartItems,
      totalPrice,
      message: "Cart retrieved successfully",
    });
  } catch (error) {
    console.error("Get user cart error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const addItemToCart = async (req : Request, res : Response) => {
    try {
        // TODO: validate request body using zod
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
        await redisClient.del(cacheKey);

        res.status(200).json({
            message: "Item added to cart successfully",
            cartItem,
        });
    } catch (error) {
        console.error("Add item to cart error:", error);
        res.status(500).json({ message: "Internal server error" });
    }
}
