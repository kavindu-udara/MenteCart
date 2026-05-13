import express from "express";
import { verifyUser } from "../middlewares/auth.middleware";
import { getUserCart } from "../controllers/cart.controller";

const router = express.Router();    

router.get('/', verifyUser, getUserCart);

export default router;
