import express from "express";
import { login, me, signup } from "../controllers/auth.controller";
import { verifyUser } from "../middlewares/auth.middleware";

const router = express.Router();

router.post('/signup', signup);
router.post('/login', login);
router.get('/me', verifyUser, me);

export default router;
