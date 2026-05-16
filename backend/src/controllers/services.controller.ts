import { NextFunction, Request, Response } from "express";
import { RedisService } from "../services/redis.service";
import { ServicesService } from "../services/services.service";
import { SlotResponse } from "../types/service";

const servicesService = new ServicesService();

export class ServicesController {
  async getAllServices(req: Request, res: Response, next: NextFunction) {
    try {
      // check cache first
      const cacheKey = `services:${JSON.stringify(req.query)}`;
      const cachedData = await RedisService.get(cacheKey);

      // if cache hit, return cached data
      if (cachedData) {
        console.log("Cache hit for services");
        return res.status(200).json(JSON.parse(cachedData));
      }

      const page = Math.max(Number(req.query.page) || 1, 1);
      const limit = Math.max(Number(req.query.limit) || 20, 1);
      const { category, search } = req.query;

      const result = await servicesService.getAllServices(
        page,
        limit,
        typeof category === "string" ? category.trim() : undefined,
        typeof search === "string" ? search.trim() : undefined,
      );

      // cache the result for 10 minutes
      await RedisService.set(
        cacheKey,
        JSON.stringify({
          ...result,
          message: "Services retrieved successfully",
        }),
        600,
      );

      res.status(200).json({
        ...result,
        message: "Services retrieved successfully",
      });
    } catch (error) {
      console.error("Get all services error:", error);
      next(error);
    }
  }

  async getServiceById(req: Request, res: Response, next: NextFunction) {
    try {
      let cacheKey : string;
      // check cache first
      cacheKey = `service:${JSON.stringify(req.query)}`;

      const { id } = req.params;
      const { date } = req.query;

      // if date is provided, we need to include it in the cache key because it affects the generated slots
      if (date && typeof date === "string") {
        cacheKey = `service:${id}:date:${date}`;
      } else {
        cacheKey = `service:${id}`;
      }

      const cachedData = await RedisService.get(cacheKey);

      // if cache hit, return cached data
      if (cachedData) {
        console.log("Cache hit for service by id");
        return res.status(200).json(JSON.parse(cachedData));
      }

      const service = await servicesService.getServiceById(id as string);

      let slots: SlotResponse[] = [];
      if (date && typeof date === "string") {
        slots = await servicesService.generateSlotsForDate(service, date);
      }

      // cache the result for 10 minutes
      await RedisService.set(
        cacheKey,
        JSON.stringify({
          service: { ...service.toObject(), slots },
          message: "Service retrieved successfully",
        }),
        600,
      );

      res
        .status(200)
        .json({
          service: { ...service.toObject(), slots },
          message: "Service retrieved successfully",
        });
    } catch (error) {
      console.error("Get service by id error:", error);
      next(error);
    }
  }
}
