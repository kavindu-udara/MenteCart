import mongoose from "mongoose";
import Service, { IService } from "../models/service.model";
import "../models/serviceCategory.model";
import { SlotResponse } from "../types/service";
import { AppError } from "../utils/appError";
import { SlotCapacity } from "../models/slotCapacity.model";

export class ServicesService {
  private BUSINESS_HOURS = { start: 9, end: 17 };

  async getAllServices(
    page: number,
    limit: number,
    categoryId?: string,
    search?: string,
  ): Promise<{ services: IService[]; total: number; hasMore: boolean }> {
    const skip = (page - 1) * limit;

    const filter: Record<string, unknown> = {};
    if (categoryId) {
      filter.categoryId = categoryId;
    }
    if (search) {
      filter.name = { $regex: search, $options: "i" };
    }

    const total = await Service.countDocuments(filter);
    const services = await Service.find(filter)
      .populate("categoryId", "name description")
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    if (services.length === 0 && page > 1) {
      throw new AppError(409, "NO_MORE_SERVICES", "No more services available");
    }

    return {
      services,
      total,
      hasMore: page * limit < total,
    };
  }

  async getServiceById(serviceId: string): Promise<IService> {
    const service = await Service.findById(serviceId).populate(
      "categoryId",
      "name description",
    );

    if (!service) {
      throw new AppError(404, "SERVICE_NOT_FOUND", "Service not found");
    }

    return service;
  }

  async generateSlotsForDate(service: IService, date: string) : Promise<SlotResponse[]> {
    const slots: SlotResponse[] = [];
    const now = new Date();
    
    // Parse the provided date and get today's date at midnight for comparison
    const providedDate = new Date(date);
    providedDate.setHours(0, 0, 0, 0);
    
    const today = new Date(now);
    today.setHours(0, 0, 0, 0);
    
    // Validate: reject past dates, only allow today or future dates
    if (providedDate < today) {
      throw new AppError(400, "INVALID_DATE", "Cannot generate slots for past dates. Only today and future dates are allowed.");
    }
    
    const startOfDay = new Date(date);
    startOfDay.setHours(this.BUSINESS_HOURS.start, 0, 0, 0);
    const endOfDay = new Date(date);
    endOfDay.setHours(this.BUSINESS_HOURS.end, 0, 0, 0);

    let currentTime = new Date(startOfDay);
    const durationMs = service.duration * 60 * 1000;

    while (true) {
      const slotEnd = new Date(currentTime.getTime() + durationMs);
      if (slotEnd.getTime() > endOfDay.getTime()) break; // Stops if slot passes closing time

      // Skip slots that already passed (only for today)
      const isToday = providedDate.getTime() === today.getTime();
      if (isToday && currentTime < now) {
        currentTime = slotEnd;
        continue;
      }

      const bookingDate = new Date(date);
      const startTimeStr = this.formatTime(currentTime);
      const { isAvailable, remainingCapacity } = await this.checkCapacity(
        service._id,
        bookingDate,
        startTimeStr,
        service.capacityPerSlot,
      );

      slots.push({
        startTime: startTimeStr,
        endTime: this.formatTime(slotEnd),
        isAvailable,
        remainingCapacity,
      });

      currentTime = slotEnd; // Jump
    }

    return slots;
  }

  private async checkCapacity(
    serviceId: mongoose.Types.ObjectId,
    date: Date,
    startTimeStr: string,
    maxCapacity: number,
  ): Promise<{ isAvailable: boolean; remainingCapacity: number }> {
    
    const capDoc = await SlotCapacity.findOne({
      serviceId,
      date,
      timeSlot: startTimeStr,
    });

    const bookedCount = capDoc ? capDoc.bookedCount : 0;
    const remaining = Math.max(0, maxCapacity - bookedCount);

    return { isAvailable: remaining > 0, remainingCapacity: remaining };
  }

  private formatTime(date: Date): string {
    return date.toTimeString().slice(0, 5);
  }
}
