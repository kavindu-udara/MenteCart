import express from 'express';
import cookieParser from 'cookie-parser';
import dotenv from 'dotenv';
import { connectDB } from './lib/db';
import authRoutes from './routes/auth.route';

dotenv.config();
await connectDB();

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

const PORT = process.env.PORT || 3000;

app.get('/test', (req, res) => {
    res.send('Hello, MenteCart!');
});

// auth routes
app.use('/api/auth', authRoutes);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
