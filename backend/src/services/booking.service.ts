import { formatPayHereAmount, generatePayHereHash } from "../lib/payhere";
import Booking, { IBooking, PaymentMethod } from "../models/booking.model";
import Cart from "../models/cart.model";
import Service from "../models/service.model";
import { SlotCapacity } from "../models/slotCapacity.model";
import User from "../models/user.model";
import { BookingResponse } from "../types/service";
import { AppError, ErrorCode } from "../utils/appError";

export class BookingService {
  private MAX_DAILY_BOOKINGS: number = parseInt(
    process.env.MAX_DAILY_BOOKINGS || "3",
    10,
  );
  private CURRENCY = process.env.PAYHERE_CURRENCY || "USD";

  private CANCELLATION_CUTOFF_HOURS: number = parseInt(
    process.env.CANCELLATION_CUTOFF_HOURS || "2",
  );

  async getBookingsByUser(userId: string): Promise<IBooking[]> {
    // get bookings for user, sorted by createdAt desc
    const bookings = await Booking.find({ userId }).sort({ createdAt: -1 });

    if (bookings.length === 0) {
      throw new AppError(404, "NO_BOOKINGS", "No bookings found for this user");
    }

    return bookings;
  }

  async getBookingById(bookingId: string, userId: string): Promise<IBooking> {
    const booking = await Booking.findOne({ _id: bookingId, userId });

    if (!booking) {
      throw new AppError(404, "BOOKING_NOT_FOUND", "Booking not found");
    }

    return booking;
  }

  async checkout(
    userId: string,
    paymentMethod: PaymentMethod,
  ): Promise<BookingResponse> {
    try {
      const cart = await Cart.findOne({ userId });
      if (!cart || cart.items.length === 0) {
        throw new AppError(400, "CART_EMPTY", "Your cart is empty");
      }

      // lazy expired item cleanup
      await this.cleanExpiredCartItems(cart);

      if (cart.items.length === 0) {
        throw new AppError(
          400,
          "CART_EXPIRED",
          "Your cart is empty after removing expired items",
        );
      }

      // daily booking limit check
      const startOfDay = new Date();
      startOfDay.setHours(0, 0, 0, 0);

      const endOfDay = new Date();
      endOfDay.setHours(23, 59, 59, 999);

      const todayBookingsCount = await Booking.countDocuments({
        userId,
        status: { $in: ["pending", "confirmed"] },
        createdAt: { $gte: startOfDay, $lte: endOfDay },
      });

      if (todayBookingsCount + cart.items.length > this.MAX_DAILY_BOOKINGS) {
        throw new AppError(
          400,
          "DAILY_BOOKING_LIMIT_EXCEEDED",
          `You can only make ${this.MAX_DAILY_BOOKINGS} bookings per day`,
        );
      }

      //  capacity recheck before finalizing booking
      for (const item of cart.items) {
        const service = await Service.findById(item.serviceId);
        if (!service) {
          throw new AppError(404, "SERVICE_NOT_FOUND", "Service not found");
        }

        let capacityDoc = await SlotCapacity.findOne({
          serviceId: item.serviceId,
          date: new Date(item.selectedDate),
          timeSlotStart: item.timeSlotStart,
          timeSlotEnd: item.timeSlotEnd,
        });

        if (!capacityDoc || capacityDoc.bookedCount > service.capacityPerSlot) {
          throw new AppError(
            409,
            "SLOT_FULL",
            `Slot ${item.timeSlotStart} for "${service.title}" is fully booked. Please choose a different slot or service.`,
          );
        }
      }

      // create booking
      const totalAmount = cart.items.reduce(
        (sum, i) => sum + i.priceAtAdd * i.quantity,
        0,
      );
      const bookingItems = cart.items.map((i) => ({
        serviceId: i.serviceId,
        selectedDate: i.selectedDate,
        timeSlotStart: i.timeSlotStart,
        timeSlotEnd: i.timeSlotEnd,
        quantity: i.quantity,
        priceAtBooking: i.priceAtAdd,
      }));

      const booking = await Booking.create({
        userId,
        status: "pending",
        paymentMethod,
        paymentStatus: paymentMethod === "payhere" ? "pending" : "unpaid",
        totalAmount,
        items: bookingItems,
        statusHistory: [{ status: "pending", timestamp: new Date() }],
      });

      await booking.save();

      //   payment method branching
      if (paymentMethod === "cash" || paymentMethod === "pay_on_arrival") {
        booking.status = "confirmed";
        booking.statusHistory.push({
          status: "confirmed",
          timestamp: new Date(),
          reason: "Auto-confirmed (cash/pay-on-arrival)",
        });
        await booking.save();
      }

      if (paymentMethod === "payhere") {
        const user = await User.findById(userId);
        if (!user) {
          throw new AppError(404, "USER_NOT_FOUND", "User not found");
        }

        const amount = booking.totalAmount;

        const hash = generatePayHereHash({
          merchant_id: process.env.PAYHERE_MERCHANT_ID!,
          order_id: booking._id.toString(),
          amount,
          currency: "USD",
          secret: process.env.PAYHERE_MERCHANT_SECRET!,
        });

        // Return payment instructions to mobile
        return {
          ...booking.toObject(),
          paymentInstructions: {
            url: process.env.PAYHERE_SANDBOX_URL,
            params: {
              merchant_id: process.env.PAYHERE_MERCHANT_ID,
              return_url: process.env.PAYHERE_RETURN_URL,
              cancel_url: process.env.PAYHERE_CANCEL_URL,
              notify_url: process.env.PAYHERE_NOTIFY_URL,
              order_id: booking._id.toString(),
              items: booking.items.map((i) => i.serviceId).join(","),
              currency: this.CURRENCY,
              amount: formatPayHereAmount(amount),
              first_name: user.firstName,
              last_name: user.lastName,
              email: user.email,
              phone: "0770000000",
              address: "Colombo",
              city: "Colombo",
              country: "Sri Lanka",
              hash,
            },
          },
        };
      }

      // clear cart
      cart.items = [];
      cart.totalAmount = 0;
      await cart.save();

      return booking;
    } catch (error) {
      console.error("Checkout error:", error);
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError(500, "CHECKOUT_FAILED", "Checkout process failed");
    }
  }

  async processPayHereWebhook(payload: {
    order_id: string;
    status_code: string;
    payhere_amount: string;
  }) {
    const booking = await Booking.findById(payload.order_id);
    if (!booking) {
      throw new AppError(
        404,
        "BOOKING_NOT_FOUND",
        "Booking not found for PayHere webhook",
      );
    }

    if (booking.status !== "pending") {
      console.log(
        `[PayHere] Ignored duplicate webhook for booking ${booking._id}`,
      );
      return booking;
    }

    const isSuccess = payload.status_code === "2"; // PayHere success code

    if (isSuccess) {
      // ✅ Payment succeeded → confirm booking
      booking.status = "confirmed";
      booking.paymentStatus = "paid";
      booking.statusHistory.push({
        status: "confirmed",
        timestamp: new Date(),
        reason: "PayHere payment success",
      });
    } else {
      // ❌ Payment failed → release capacity
      booking.status = "failed";
      booking.paymentStatus = "failed";
      booking.statusHistory.push({
        status: "failed",
        timestamp: new Date(),
        reason: `PayHere status_code: ${payload.status_code}`,
      });

      // 📉 Release held capacity back to pool
      await this.releaseBookingCapacity(booking);
    }

    await booking.save();
    return booking;
  }

  private async releaseBookingCapacity(booking: any): Promise<void> {
    const bulkOps = booking.items.map((item: any) => ({
      updateOne: {
        filter: {
          serviceId: item.serviceId,
          date: item.selectedDate,
          timeSlotStart: item.timeSlotStart,
          timeSlotEnd: item.timeSlotEnd,
          bookedCount: { $gte: item.quantity }, // Safety guard
        },
        update: { $inc: { bookedCount: -item.quantity } },
      },
    }));

    if (bulkOps.length > 0) {
      await SlotCapacity.bulkWrite(bulkOps);
    }
  }

  async cancelBooking(userId: string, bookingId: string): Promise<IBooking> {
    try {
      const booking = await Booking.findById(bookingId);

      if (!booking) {
        throw new AppError(404, "BOOKING_NOT_FOUND", "Booking not found");
      }

      if (booking.userId.toString() !== userId) {
        throw new AppError(
          403,
          "FORBIDDEN",
          "You are not allowed to cancel this booking",
        );
      }

      // validate cut off rules
      const now = new Date();
      for (const item of booking.items) {
        const slotStart = new Date(item.selectedDate);
        const [hours, minutes] = item.timeSlotStart.split(":").map(Number);
        slotStart.setHours(hours, minutes, 0, 0);

        const hoursUntilSlot =
          (slotStart.getTime() - now.getTime()) / (1000 * 60 * 60);
        if (hoursUntilSlot < this.CANCELLATION_CUTOFF_HOURS) {
          throw new AppError(
            400,
            "CANCELLATION_CUTOFF_PASSED",
            `Cancellations not allowed within ${this.CANCELLATION_CUTOFF_HOURS} hours of the appointment`,
          );
        }
      }

      const validStatuses = ["pending", "confirmed"];
      if (!validStatuses.includes(booking.status)) {
        throw new AppError(
          400,
          "CANCELLATION_NOT_ALLOWED",
          `Only bookings with status ${validStatuses.join(
            " or ",
          )} can be cancelled`,
        );
      }

      // release capacity back to pool
      if (booking.status === "pending" || booking.status === "confirmed") {
        const bulkOps = booking.items.map((item) => ({
          updateOne: {
            filter: {
              serviceId: item.serviceId,
              date: new Date(item.selectedDate).setHours(0, 0, 0, 0), // normalize
              timeSlotStart: item.timeSlotStart,
              timeSlotEnd: item.timeSlotEnd,
              bookedCount: { $gte: item.quantity },
            },
            update: { $inc: { bookedCount: -item.quantity } },
          },
        }));

        if (bulkOps.length > 0) {
          await SlotCapacity.bulkWrite(bulkOps);
        }
      }

      // update booking status
      booking.status = "cancelled";
      booking.cancelledAt = new Date();
      booking.statusHistory.push({
        status: "cancelled",
        timestamp: new Date(),
        reason: "Cancelled by user",
      });
      await booking.save();

      return booking;
    } catch (error) {
      console.error("Cancel booking error:", error);
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError(
        500,
        "CANCEL_BOOKING_FAILED",
        "Failed to cancel booking",
      );
    }
  }

  private async cleanExpiredCartItems(cart: any): Promise<void> {
    const EXPIRY_MS = 15 * 60 * 1000;
    const threshold = new Date(Date.now() - EXPIRY_MS);
    const expired = cart.items.filter((i: any) => i.addedAt < threshold);

    if (expired.length === 0) return;

    // Release capacity
    const bulkOps = expired.map((item: any) => ({
      updateOne: {
        filter: {
          serviceId: item.serviceId,
          date: item.selectedDate,
          timeSlotStart: item.timeSlotStart,
          timeSlotEnd: item.timeSlotEnd,
          bookedCount: { $gte: item.quantity },
        },
        update: { $inc: { bookedCount: -item.quantity } },
      },
    }));
    await SlotCapacity.bulkWrite(bulkOps);

    // Remove from cart
    const expiredIds = new Set(expired.map((i: any) => i._id.toString()));
    cart.items = cart.items.filter(
      (i: any) => !expiredIds.has(i._id.toString()),
    );
    cart.totalAmount = cart.items.reduce(
      (sum: number, i: any) => sum + i.priceAtAdd * i.quantity,
      0,
    );
  }
}
