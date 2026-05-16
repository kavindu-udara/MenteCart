# MenteCart
> A production-leaning service booking application with time-bound cart, atomic capacity management, and secure payment flow.

## Overview
MenteCart allows users to browse a catalogue of time-bound services, select specific dates/slots, reserve them in a server-side cart, and complete bookings via secure payment (PayHere) or offline methods. Unlike traditional e-commerce carts, every item represents a capacity-constrained time slot with strict expiry, atomic overbooking prevention, and a guarded status lifecycle.

## Tech Stack
| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter 3.x (Dart 3), BLoC Pattern, Dio, `webview_flutter` |
| **Backend** | Node.js, Express, TypeScript |
| **Database** | MongoDB + Mongoose |
| **Auth** | JWT Access Tokens (bcrypt ≥ 10 rounds) |
| **Payment** | PayHere Sandbox (MD5 hash verification, idempotent webhooks) |
| **Testing** | Jest, Supertest |
| **Tooling** | Docker, ESLint, Prettier, `dotenv`, `ngrok` (local webhook testing) |


## Architecture & Key Decisions
| Decision | Why |
|----------|-----|
| **Server-side cart** | Ensures slot reservation syncs across devices, enables secure 15-min expiry, and prevents client-side tampering. |
| **Atomic capacity checks** | Used `findOneAndUpdate` with `$expr` + `$inc` inside MongoDB transactions. Prevents race conditions where two users book the last slot simultaneously. |
| **Slot generation on-demand** | Slots are not stored in the DB. They're calculated dynamically based on `service.duration`, business hours, and `SlotCapacity` tracker. Keeps collections lean and query-fast. |
| **BLoC for all state** | Required by assessment. Forces explicit event/state flows, simplifies testing, and cleanly separates UI from business logic. |
| **Idempotent webhook handling** | PayHere may retry callbacks. The webhook checks `booking.status !== 'pending'` before processing, preventing double-confirmations or duplicate capacity releases. |
| **Strict PayHere hash format** | Amount formatted to `X.00` per official docs. Secret hashed first, then concatenated. Final hash uppercased. Matches sandbox validation exactly. |

## Prerequisites
- Node.js `v18+` & npm/yarn
- Flutter `v3.16+` & Dart `v3.2+`
- MongoDB (local instance or Atlas cluster)
- Redis
- Git & GitHub CLI (optional)
- Docker

## Environment Setup
Create `.env` files in `/backend` and `/mobile`.

### `/backend/.env.example`
```env
HOST=0.0.0.0
PORT=3000

MONGODB_URI=mongodb://localhost:27017/mentecart
REDIS_URL=redis://localhost:6379

MAX_DAILY_BOOKINGS=3
CANCELLATION_CUTOFF_HOURS=2

JWT_SECRET=your_strong_jwt_secret_here
JWT_EXPIRES_IN=24h

PAYHERE_MERCHANT_ID=your_sandbox_merchant_id
PAYHERE_MERCHANT_SECRET=your_sandbox_secret
PAYHERE_SANDBOX_URL=
PAYHERE_PRODUCTION_URL= # required if sandbox is false
PAYHERE_NOTIFY_URL=https://<your-ngrok-url>/webhooks/payhere
PAYHERE_RETURN_URL=https://<your-ngrok-url>/payment/return
PAYHERE_RETURN_URL=
PAYHERE_CANCEL_URL=https://<your-ngrok-url>/payment/cancel
PAYHERE_IS_SANDBOX=true
PAYHERE_CURRENCY=USD # or LKR
```

### `/mobile/.env.example`
```env
API_BASE_URL=
```

## Local Setup Guide

### Backend

1. Clone the repo
```bash
git clone https://github.com/kavindu-udara/MenteCart.git
```
2. Go to `backend` dir
```bash
cd backend
```
3. Copy `.env.example` to `.env`
```bash
cp .env.example .env
```
4. Setup your env and install
```bash
pnpm install
```
5. Start development server
```bash
pnpm dev
```

### Docker setup
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

## Mobile
```bash
cd mobile
flutter pub get
flutter run 
```

## Services

- App: `http://localhost:3000`
- MongoDB: `mongodb://localhost:27017`
- Redis: `redis://localhost:6379`

## TODO
- [ ] Payhere intergration

