import Service, { IService } from "../models/service.model";
import "../models/serviceCategory.model";
import { AppError } from "../utils/appError";

export class ServicesService {
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
}
