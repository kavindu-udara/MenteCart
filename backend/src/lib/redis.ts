import redis from "redis";

let client: redis.RedisClientType | null = null;

const createRedisClient = async () => {
  if (!client) {
    client = redis.createClient({
      url: process.env.REDIS_URL || "redis://localhost:6379",
    });

    client.on("error", (err) => {
      console.error("Redis Client Error", err);
    });

    client.on("connect", () => {
      console.log("Connected to Redis successfully");
    });

    await client.connect();
  }

  return client;
};

export default createRedisClient;
