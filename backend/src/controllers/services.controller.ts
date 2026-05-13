import { Request, Response } from "express";
import Service from "../models/service.model";

export const getAllServices = async (req: Request, res: Response) => {
  try {
    // TODO: add pagination and filtering by category in future

    // get all services from db
    const services = await Service.find();

    if (services.length === 0) {
      return res.status(404).json({ message: "No services found" });
    }

    res
      .status(200)
      .json({ services, message: "Services retrieved successfully" });
  } catch (error) {
    console.error("Get all services error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const getServiceById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // get service by id from db
    const service = await Service.findById(id);

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
