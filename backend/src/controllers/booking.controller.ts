import { NextFunction, Request, Response } from "express";

export class BookingController {
    async getBookings(req: Request, res: Response, next: NextFunction) {
        try {
            
        } catch (error) {
            console.error("Get bookings error:", error);
            next(error);
        }
    }
}
