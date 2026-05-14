import express from "express";
import { ServicesController } from "../controllers/services.controller";

const router = express.Router();
const serviceController = new ServicesController();

router.get("/", serviceController.getAllServices);
router.get("/:id", serviceController.getServiceById);

export default router;
