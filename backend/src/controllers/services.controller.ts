import { Request, Response } from "express";
import "../models/serviceCategory.model";
import Service from "../models/service.model";

export const getAllServices = async (req: Request, res: Response) => {
  try {
    const page = Math.max(Number(req.query.page) || 1, 1);
    const limit = Math.max(Number(req.query.limit) || 20, 1);
    const skip = (page - 1) * limit;

    const total = await Service.countDocuments();
    const services = await Service.find()
      .populate("categoryId", "name description")
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    const hasMore = page * limit < total;

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
