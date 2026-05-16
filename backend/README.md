# MenteCart Backend

## Local Docker Setup

1. Copy the example environment file:

```bash
cp .env.example .env
```

2. Start the full stack:

```bash
docker compose up --build
```

If you want it detached:

```bash
docker compose up --build -d
```

3. Run db seeder
```bash
docker-compose exec app pnpm run seed
```

## Services

- App: `http://localhost:3000`
- MongoDB: `mongodb://localhost:27017`
- Redis: `redis://localhost:6379`
