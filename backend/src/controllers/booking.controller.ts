import { NextFunction, Request, Response } from "express";
import { BookingService } from "../services/booking.service";
import { RedisService } from "../services/redis.service";
import { bookingCheckoutSchema, payhereCheckoutSchema } from "../lib/zodSchemas";
import { AppError, ErrorCode } from "../utils/appError";

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

  async checkout(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.decoded.userId;

      const result = bookingCheckoutSchema.safeParse(req.body);

      if (!result.success) {
        const errors = result.error.flatten().fieldErrors;
        return next(
          new AppError(400, ErrorCode.VALIDATION_ERROR, JSON.stringify(errors)),
        );
      }

      const { paymentMethod } = result.data;

      const booking = await bookingService.checkout(userId, paymentMethod);

      // invalidate bookings cache
      const cacheKey = `bookings:${userId}`;
      await RedisService.del(cacheKey);

      res.status(200).json({booking, message: "Checkout successful" });
    } catch (error) {
      console.error("Checkout error:", error);
      next(error);
    }
  }

  async getBookingById(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.decoded.userId;
      const { bookingId } = req.params;

      if (bookingId && typeof bookingId !== "string") {
        return next(
          new AppError(
            400,
            ErrorCode.VALIDATION_ERROR,
            "Invalid booking ID format",
          ),
        );
      }

      // check cache first
      const cacheKey = `booking:${bookingId}`;
      const cachedData = await RedisService.get(cacheKey);

      // if cache hit, return cached data
      if (cachedData) {
        console.log("Cache hit for booking by id");
        return res.status(200).json(JSON.parse(cachedData));
      }

      const booking = await bookingService.getBookingById(bookingId, userId);

      // cache the result for 10 minutes
      await RedisService.set(
        cacheKey,
        JSON.stringify({ booking, message: "Booking retrieved successfully" }),
        600,
      );

      res
        .status(200)
        .json({ booking, message: "Booking retrieved successfully" });
    } catch (error) {
      console.error("Get booking by id error:", error);
      next(error);
    }
  }

  async cancelBooking(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.decoded.userId;
      const { bookingId } = req.params;

      if (bookingId && typeof bookingId !== "string") {
        return next(
          new AppError(
            400,
            ErrorCode.VALIDATION_ERROR,
            "Invalid booking ID format",
          ),
        );
      }

      const cancelledBooking = await bookingService.cancelBooking(
        userId,
        bookingId,
      );

      // invalidate bookings cache
      const cacheKey = `bookings:${userId}`;
      await RedisService.del(cacheKey);

      res
        .status(200)
        .json({
          booking: cancelledBooking,
          message: "Booking cancelled successfully",
        });
    } catch (error) {
      console.error("Cancel booking error:", error);
      next(error);
    }
  }
}
