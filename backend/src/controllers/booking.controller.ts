import { NextFunction, Request, Response } from "express";
import { BookingService } from "../services/booking.service";
import { RedisService } from "../services/redis.service";

const bookingService = new BookingService();

export class BookingController {
  async getBookings(req: Request, res: Response, next: NextFunction) {
    try {
      // check cache first
      const cacheKey = `bookings:${req.decoded.userId}`;
      const cachedData = await RedisService.get(cacheKey);

      // if cache hit, return cached data
      if (cachedData) {
        console.log("Cache hit for bookings");
        return res.status(200).json(JSON.parse(cachedData));
      }

      const userId = req.decoded.userId;
      const bookings = await bookingService.getBookingsByUser(userId);

      // cache the result for 5 minutes
      await RedisService.set(
        cacheKey,
        JSON.stringify({
          bookings,
          message: "Bookings retrieved successfully",
        }),
        300,
      );

      res
        .status(200)
        .json({ bookings, message: "Bookings retrieved successfully" });
    } catch (error) {
      console.error("Get bookings error:", error);
      next(error);
    }
  }
}
