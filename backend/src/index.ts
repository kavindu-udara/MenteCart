import express from 'express';
import cookieParser from 'cookie-parser';
import dotenv from 'dotenv';
import { connectDB } from './lib/db';
import authRoutes from './routes/auth.route';
import servicesRoutes from './routes/services.route';
import createRedisClient from './lib/redis';

dotenv.config();
await connectDB();

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// redis
await createRedisClient();

const PORT = process.env.PORT || 3000;

app.get('/test', (req, res) => {
    res.send('Hello, MenteCart!');
});

// auth routes
app.use('/api/auth', authRoutes);
// services routes
app.use('/api/services', servicesRoutes);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
