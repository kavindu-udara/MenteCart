import express from "express";
import { ServicesController } from "../controllers/services.controller";
import { verifyUser } from "../middlewares/auth.middleware";

const router = express.Router();
const serviceController = new ServicesController();

router.get("/", verifyUser,serviceController.getAllServices);
router.get("/:id", verifyUser, serviceController.getServiceById);

export default router;
