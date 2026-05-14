import express from "express";
import { verifyUser } from "../middlewares/auth.middleware";
import { BookingController } from "../controllers/booking.controller";

const bookingController = new BookingController();

const router = express.Router();
router.get("/", verifyUser, bookingController.getBookings);

export default router;
