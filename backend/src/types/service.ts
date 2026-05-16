import { IBooking } from "../models/booking.model";
import { PaymentInstructions } from "./payhere";

export interface SlotResponse {
  startTime: string;    
  endTime: string;       
  isAvailable: boolean;
  remainingCapacity: number;
}

export interface BookingResponse extends IBooking {
  paymentInstructions? : PaymentInstructions;
}