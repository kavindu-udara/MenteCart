import express from "express";
import { verifyUser } from "../middlewares/auth.middleware";
import { addItemToCart, CartController, getUserCart } from "../controllers/cart.controller";

const router = express.Router();    
const cartController = new CartController();

router.get('/', verifyUser, cartController.getCart);
router.post('/items', verifyUser, cartController.addItem);

export default router;
