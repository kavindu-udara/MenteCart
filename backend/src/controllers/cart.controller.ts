import { Request, Response } from "express";
import createRedisClient from "../lib/redis";
import CartItem from "../models/cartItem.model";

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

    const cartItems = await CartItem.find({ userId }).populate(
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
