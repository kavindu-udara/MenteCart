import express from 'express';
import cookieParser from 'cookie-parser';
import pino from 'pino-http';

import authRoutes from './routes/auth.route';
import servicesRoutes from './routes/services.route';
import cartRoutes from './routes/cart.route';
import bookingRoutes from './routes/booking.route';
import webhookRoutes from './routes/webhook.routes';

import { errorMiddleware } from './middlewares/error.middleware';

const app = express();

// pino logger
app.use(pino());

app.use(webhookRoutes); 

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

app.get('/', (req, res) => {
    res.json({ message: 'Hello World' });
});

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

export default app;
