import { CronJob } from "cron";
import Cart from "../models/cart.model";
import { SlotCapacity } from "../models/slotCapacity.model";

export const cartJob = new CronJob("*/5 * * * *", async () => {
  try {
    const expiryThreshold = new Date(Date.now() - 15 * 60 * 1000);
    const carts = await Cart.find({
      "items.addedAt": { $lt: expiryThreshold },
    });

    console.log(`[Cron] Found ${carts.length} carts with expired items`);

    for (const cart of carts) {
      const expired = cart.items.filter((i) => i.addedAt < expiryThreshold);
      if (expired.length === 0) continue;

      cart.items = cart.items.filter((i) => i.addedAt >= expiryThreshold);
      cart.totalAmount = cart.items.reduce(
        (s, i) => s + i.priceAtAdd * i.quantity,
        0,
      );
      await cart.save();

      console.log(
        `[Cron] Cleaned ${expired.length} expired items from cart ${cart._id}`,
      );

      // Bulk release capacity
      await SlotCapacity.bulkWrite(
        expired.map((i) => ({
          updateOne: {
            filter: {
              serviceId: i.serviceId,
              date: i.selectedDate,
              timeSlotStart: i.timeSlotStart,
              timeSlotEnd: i.timeSlotEnd,
            },
            update: { $inc: { bookedCount: -1 } },
          },
        })),
      );

      console.log(
        `[Cron] Released capacity for ${expired.length} expired items from cart ${cart._id}`,
      );
    }
  } catch (error) {
    console.error("[Cron] error in callback", error);
  }
});
