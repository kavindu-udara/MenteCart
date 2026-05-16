import dotenv from "dotenv";
import { DB } from "./lib/db";
import { RedisService } from "./services/redis.service";
import { cartJob } from "./lib/cron";
import app from "./app";

dotenv.config();

const HOST = process.env.HOST || "localhost";
const PORT = process.env.PORT ? parseInt(process.env.PORT) : 3000;

async function startServer() {
  // connect to database and redis before starting the HTTP server
  await DB.connect();
  await RedisService.create();

  // start cron jobs after services are ready
  cartJob.start();

  return new Promise<void>((resolve) => {
    app.listen(PORT, HOST, () => {
      console.log(`Server is running on port ${HOST}:${PORT}`);
      resolve();
    });
  });
}

await startServer();
