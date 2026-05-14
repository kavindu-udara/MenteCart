import express from "express";
import { AuthController } from "../controllers/auth.controller";
import { verifyUser } from "../middlewares/auth.middleware";

const router = express.Router();
const authController = new AuthController();

router.post("/signup", authController.signup);
router.post("/login", authController.login);
router.get("/me", verifyUser, authController.me);

export default router;
