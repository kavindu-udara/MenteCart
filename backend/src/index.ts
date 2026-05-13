import express from 'express';
import dotenv from 'dotenv';
import { connectDB } from './lib/db';

dotenv.config();
await connectDB();

const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.send('Hello, MenteCart!');
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
