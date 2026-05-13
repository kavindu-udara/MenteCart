import express from "express";

const router = express.Router();

router.get('/');
router.get('/:id');

export default router;
