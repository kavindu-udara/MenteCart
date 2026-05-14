import mongoose from "mongoose";
import Cart, { ICart } from "../models/cart.model";
import Service from "../models/service.model";
import { SlotCapacity } from "../models/slotCapacity.model";
import { AppError, ErrorCode } from "../utils/appError";
import { ICartItem } from "../models/cartItem.model";

const CART_EXPIRY_MS = 15 * 60 * 1000; // 15 min

export class CartService {
  async getCart(userId: string): Promise<ICart> {
    let cart = await Cart.findOne({ userId });
    if (!cart) {
      cart = await Cart.create({ userId, items: [], totalAmount: 0 });
    }
    // Lazy cleanup
    await this.cleanExpiredItems(cart);
    await cart.save();
    return cart;
  }

  async addItem(
    userId: string,
    serviceId: string,
    selectedDate: string,
    timeSlotStart: string,
    timeSlotEnd: string,
  ): Promise<ICart> {
    try {
      const service = await Service.findById(serviceId);
      if (!service)
        throw new AppError(
          404,
          ErrorCode.SERVICE_NOT_FOUND,
          "Service not found",
        );

      // Check capacity for the slot
      const capacityDoc = await SlotCapacity.findOneAndUpdate(
        {
          serviceId: service._id,
          date: new Date(selectedDate),
          timeSlotStart: timeSlotStart,
          timeSlotEnd: timeSlotEnd,
        },
        { $inc: { bookedCount: 1 } },
        { upsert: true, new: true },
      );

      if (!capacityDoc) {
        throw new AppError(
          409,
          ErrorCode.SLOT_FULL,
          "This time slot is fully booked",
        );
      }

      // Get/Create cart & clean expired
      let cart = await Cart.findOne({ userId });
      if (!cart)
        cart = await Cart.create({ userId, items: [], totalAmount: 0 });
      await this.cleanExpiredItems(cart);

      // Prevent duplicate slot in cart
      const exists = cart.items.some(
        (item) =>
          item.serviceId.toString() === serviceId &&
          new Date(item.selectedDate).getTime() ===
            new Date(selectedDate).getTime() &&
          item.timeSlotStart === timeSlotStart &&
          item.timeSlotEnd === timeSlotEnd,
      );
      if (exists)
        throw new AppError(
          409,
          ErrorCode.ITEM_DUPLICATE,
          "Slot already in cart",
        );

      // Add item with price snapshot
      const newItem: ICartItem = {
        _id: new mongoose.Types.ObjectId(),
        serviceId: service._id,
        selectedDate: new Date(selectedDate),
        timeSlotStart: timeSlotStart,
        timeSlotEnd: timeSlotEnd,
        quantity: 1,
        priceAtAdd: service.price,
        addedAt: new Date(),
      };

      cart.items.push(newItem);
      this.recalculateTotal(cart);
      await cart.save();

      return cart;
    } catch (err) {
      throw err;
    }
  }

  async removeItem(userId: string, itemId: string): Promise<ICart> {
    try {
      const cart = await Cart.findOne({ userId });
      if (!cart) throw new AppError(404, "CART_NOT_FOUND", "Cart not found");

      const itemIndex = cart.items.findIndex(
        (i) => i._id.toString() === itemId,
      );
      if (itemIndex === -1)
        throw new AppError(404, "ITEM_NOT_FOUND", "Item not in cart");

      const item = cart.items[itemIndex];

      const capacityResult = await SlotCapacity.updateOne(
        {
          serviceId: item.serviceId,
          date: new Date(item.selectedDate).setHours(0, 0, 0, 0), // normalize
          timeSlotStart: item.timeSlotStart,
          bookedCount: { $gt: 0 }, // sanity check
        },
        { $inc: { bookedCount: -1 } },
      );

      //   if no capacity doc found
      if (capacityResult.matchedCount === 0) {
        console.warn(
          `Capacity doc not found when removing item ${itemId} from cart ${cart._id}. This may indicate a data inconsistency.`,
        );
      }

      cart.items.splice(itemIndex, 1);
      this.recalculateTotal(cart);

      await cart.save();

      return cart;
    } catch (err) {
      throw err;
    }
  }

  async updateItem(
    userId: string,
    itemId: string,
    selectedDate: string,
    timeSlotStart: string,
    timeSlotEnd: string,
  ): Promise<ICart> {
    try {
      const cart = await Cart.findOne({ userId });
      if (!cart) throw new AppError(404, "CART_NOT_FOUND", "Cart not found");

      const itemIndex = cart.items.findIndex(
        (i) => i._id.toString() === itemId,
      );
      if (itemIndex === -1)
        throw new AppError(404, "ITEM_NOT_FOUND", "Item not in cart");

      const item = cart.items[itemIndex];

      // Check capacity for new slot
      const capacityDoc = await SlotCapacity.findOneAndUpdate(
        {
          serviceId: item.serviceId,
          date: new Date(selectedDate),
          timeSlotStart: timeSlotStart,
          timeSlotEnd: timeSlotEnd,
        },
        { $inc: { bookedCount: 1 } },
        { upsert: true, new: true },
      );

      if (!capacityDoc) {
        throw new AppError(
          409,
          ErrorCode.SLOT_FULL,
          "This time slot is fully booked",
        );
      }

      // Release old slot
      await SlotCapacity.updateOne(
        {
          serviceId: item.serviceId,
          date: item.selectedDate,
          timeSlotStart: item.timeSlotStart,
          timeSlotEnd: item.timeSlotEnd,
        },
        { $inc: { bookedCount: -1 } },
      );

      // Update item details
      item.selectedDate = new Date(selectedDate);
      item.timeSlotStart = timeSlotStart;
      item.timeSlotEnd = timeSlotEnd;
      item.addedAt = new Date(); // reset expiry

      this.recalculateTotal(cart);
      return cart;
    } catch (err) {
      throw err;
    }
  }

  // Lazy expiry cleanup
  private async cleanExpiredItems(cart: ICart): Promise<void> {
    const expiryThreshold = new Date(Date.now() - CART_EXPIRY_MS);
    const expiredItems = cart.items.filter((i) => i.addedAt < expiryThreshold);

    if (expiredItems.length === 0) return;

    const expiredIds = new Set(expiredItems.map((i) => i._id));
    cart.items = cart.items.filter((i) => !expiredIds.has(i._id));

    // Release capacity for all expired items
    if (expiredItems.length > 0) {
      const bulkOps = expiredItems.map((item) => ({
        updateOne: {
          filter: {
            serviceId: item.serviceId,
            date: item.selectedDate,
            timeSlotStart: item.timeSlotStart,
            timeSlotEnd: item.timeSlotEnd,
          },
          update: { $inc: { bookedCount: -1 } },
        },
      }));
      await SlotCapacity.bulkWrite(bulkOps);
    }

    this.recalculateTotal(cart);
  }

  private recalculateTotal(cart: ICart): void {
    cart.totalAmount = cart.items.reduce(
      (sum, item) => sum + item.priceAtAdd * item.quantity,
      0,
    );
  }
}
