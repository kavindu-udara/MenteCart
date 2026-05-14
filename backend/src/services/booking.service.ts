import Booking, { IBooking, PaymentMethod } from "../models/booking.model";
import Cart from "../models/cart.model";
import Service from "../models/service.model";
import { SlotCapacity } from "../models/slotCapacity.model";
import { AppError } from "../utils/appError";

export class BookingService {
  private MAX_DAILY_BOOKINGS: number = parseInt(
    process.env.MAX_DAILY_BOOKINGS || "3",
    10,
  );

  async getBookingsByUser(userId: string): Promise<IBooking[]> {
    // get bookings for user, sorted by createdAt desc
    const bookings = await Booking.find({ userId }).sort({ createdAt: -1 });

    if (bookings.length === 0) {
      throw new AppError(404, "NO_BOOKINGS", "No bookings found for this user");
    }

    return bookings;
  }

  async checkout(
    userId: string,
    paymentMethod: PaymentMethod,
  ): Promise<IBooking> {
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
        },
        update: { $inc: { bookedCount: -1 } },
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
