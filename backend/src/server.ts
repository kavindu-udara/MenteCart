import app from "./app";
import dotenv from "dotenv";

dotenv.config();

const HOST = process.env.HOST || "localhost";
const PORT = process.env.PORT ? parseInt(process.env.PORT) : 3000;

async function startServer() {
  return new Promise<void>((resolve) => {
    app.listen(PORT, HOST, () => {
      console.log(`Server is running on port ${HOST}:${PORT}`);
      resolve();
    });
  });
}

await startServer();
