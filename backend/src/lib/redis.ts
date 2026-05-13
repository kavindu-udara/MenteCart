import redis from "redis";

const createRedisClient = async () => {
  const client = redis.createClient({
    url: process.env.REDIS_URL || "redis://localhost:6379",
  });

  client.on("error", (err) => {
    console.error("Redis Client Error", err);
  });

  client.on("connect", () => {
    console.log("Connected to Redis successfully");
  });

  await client.connect();
  return client;
};

export default createRedisClient;
