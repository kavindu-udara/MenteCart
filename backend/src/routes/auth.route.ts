import express from "express";
import { login, me, signup } from "../controllers/auth.controller";

const router = express.Router();

router.post('/signup', signup);
router.post('/login', login);
router.get('/me', me);

export default router;
