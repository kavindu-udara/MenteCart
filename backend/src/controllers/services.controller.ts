import mongoose from "mongoose";
import { Request, Response } from "express";
import ServiceCategory from "../models/serviceCategory.model";
import Service from "../models/service.model";
import createRedisClient from "../lib/redis";

const escapeRegex = (value: string) =>
  value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

export const getAllServices = async (req: Request, res: Response) => {
  try {
    const redisClient = await createRedisClient();

    // check cache first
    const cacheKey = `services:${JSON.stringify(req.query)}`;
    const cachedData = await redisClient.get(cacheKey);

    // if cache hit, return cached data
    if (cachedData) {
      console.log("Cache hit for services");
      return res.status(200).json(JSON.parse(cachedData));
    }

    const page = Math.max(Number(req.query.page) || 1, 1);
    const limit = Math.max(Number(req.query.limit) || 20, 1);
    const skip = (page - 1) * limit;

    const filter: Record<string, unknown> = {};
    const categoryParam =
      typeof req.query.category === "string" ? req.query.category.trim() : "";

    if (categoryParam) {
      if (mongoose.Types.ObjectId.isValid(categoryParam)) {
        filter.categoryId = categoryParam;
      } else {
        const category = await ServiceCategory.findOne({
          name: new RegExp(`^${escapeRegex(categoryParam)}$`, "i"),
        });

        if (!category) {
          return res.status(404).json({ message: "Category not found" });
        }

        filter.categoryId = category._id;
      }
    }

    const total = await Service.countDocuments(filter);
    const services = await Service.find(filter)
      .populate("categoryId", "name description")
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    const hasMore = page * limit < total;

    // cache the result for 10 minutes
    await redisClient.setEx(
      cacheKey,
      600,
      JSON.stringify({
        services,
        total,
        hasMore,
        page,
        limit,
      }),
    );

    res.status(200).json({
      services,
      total,
      hasMore,
      page,
      limit,
      message: "Services retrieved successfully",
    });
    
  } catch (error) {
    console.error("Get all services error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getServiceById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const service = await Service.findById(id).populate(
      "categoryId",
      "name description",
    );

    if (!service) {
      return res.status(404).json({ message: "Service not found" });
    }

    res
      .status(200)
      .json({ service, message: "Service retrieved successfully" });
  } catch (error) {
    console.error("Get service by id error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
