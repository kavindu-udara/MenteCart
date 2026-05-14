import Booking, { IBooking } from "../models/booking.model";
import { AppError } from "../utils/appError";

export class BookingService {
    async getBookingsByUser(userId: string) : Promise<IBooking[]> {
        // get bookings for user, sorted by createdAt desc
        const bookings = await Booking.find({ userId }).sort({ createdAt: -1 });
        
        if(bookings.length === 0) {
            throw new AppError(404, "NO_BOOKINGS", "No bookings found for this user");
        }

        return bookings;

    }
}
