import express from "express";
import { verifyUser } from "../middlewares/auth.middleware";
import { addItemToCart, getUserCart } from "../controllers/cart.controller";

const router = express.Router();    

router.get('/', verifyUser, getUserCart);
router.post('/items', verifyUser, addItemToCart);

export default router;
