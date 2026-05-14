import redis from "redis";
import { AppError, ErrorCode } from "../utils/appError";

export class RedisService {
  private static client: ReturnType<typeof redis.createClient> | null = null;
  private static connecting: Promise<ReturnType<typeof redis.createClient>> | null = null;

  static async create(): Promise<ReturnType<typeof redis.createClient>> {
    if (this.client) {
      return this.client;
    }

    if (!this.connecting) {
      const client = redis.createClient({
        url: process.env.REDIS_URL || "redis://localhost:6379",
      });

      client.on("connect", () => {
        console.log("Connected to Redis successfully");
      });

      client.on("error", (err) => {
        console.error("Redis Client Error", err);
      });

      this.connecting = client
        .connect()
        .then(() => {
          this.client = client;
          return client;
        })
        .catch((error) => {
          this.connecting = null;
          throw new AppError(
            500,
            ErrorCode.REDIS_CONNECTION_ERROR,
            error instanceof Error
              ? `Failed to connect to Redis: ${error.message}`
              : "Failed to connect to Redis",
          );
        });
    }

    return await this.connecting;
  }

  static async set(key: string, value: string, expirySeconds?: number) {
    const client = await this.create();

    if (expirySeconds) {
      await client.setEx(key, expirySeconds, value);
    } else {
      await client.set(key, value);
    }
  }

  static async get(key: string): Promise<string | null> {
    const client = await this.create();
    return await client.get(key);
  }

  static async del(key: string) {
    const client = await this.create();
    await client.del(key);
  }
}
