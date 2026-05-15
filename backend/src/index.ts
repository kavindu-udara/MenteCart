import express from 'express';
import cookieParser from 'cookie-parser';
import dotenv from 'dotenv';

import authRoutes from './routes/auth.route';
import servicesRoutes from './routes/services.route';
import cartRoutes from './routes/cart.route';
import bookingRoutes from './routes/booking.route';

import { errorMiddleware } from './middlewares/error.middleware';
import { RedisService } from './services/redis.service';
import { DB } from './lib/db';
import { cartJob } from './lib/cron';

dotenv.config();

// connect to database
await DB.connect();

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// redis
await RedisService.create();

// start cart cron job
cartJob.start();

const HOST = process.env.HOST || 'localhost';
const PORT = process.env.PORT ?  parseInt(process.env.PORT) : 3000;

app.get('/test', (req, res) => {
    res.send('Hello, MenteCart!');
});

// auth routes
app.use('/api/auth', authRoutes);
// services routes
app.use('/api/services', servicesRoutes);
// cart routes
app.use('/api/cart', cartRoutes);
// booking routes
app.use('/api/bookings', bookingRoutes);

// 404 for undefined routes
app.use((req, res) => {
    res.status(404).json({ message: 'Route not found' });
});

app.use(errorMiddleware);

app.listen(PORT, HOST, () => {
    console.log(`Server is running on port ${HOST}:${PORT}`);
});
