import express from "express";
import { verifyUser } from "../middlewares/auth.middleware";
import { CartController } from "../controllers/cart.controller";

const router = express.Router();    
const cartController = new CartController();

router.get('/', verifyUser, cartController.getCart);
router.post('/items', verifyUser, cartController.addItem);
router.patch('/items/:itemId', verifyUser, cartController.updateItem);
router.delete('/items/:itemId', verifyUser, cartController.removeItem);

export default router;
