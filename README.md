# OpenRSVP Docker Deployment

This repository contains everything you need to deploy **OpenRSVP**—the ultimate self-hosted event management and RSVP platform—using Docker.

![OpenRSVP Dashboard Preview](https://openrsvp.korex.ovh/main-screen.webp)

OpenRSVP is a modern, privacy-first alternative to expensive SaaS wedding and event planners. By deploying this Docker image on your own server (DigitalOcean, AWS, Hetzner, etc.), you retain 100% control over your guests' data.

## Features Included
- **Minimal Standalone Build:** The Dockerfile builds a Next.js `standalone` image to keep memory footprint incredibly low.
- **Caddy Reverse Proxy:** Automatically provisions and renews free SSL/TLS certificates via Let's Encrypt.
- **Native Prisma Database Connection:** Uses native TCP connections to seamlessly connect to Neon Postgres or any standard Postgres database.

---

## 🚀 Deployment Guide (Production)

Follow these steps to deploy OpenRSVP to a live server with a custom domain.

### 1. Configure your Domain
Point your domain's A-Record to your server's IP address. Then, open the `Caddyfile` and replace `yourdomain.com` with your actual domain name.

### 2. Configure Environment Variables
Rename `.env.example` to `.env`.
```bash
cp .env.example .env
```
Open `.env` and fill in your credentials. At minimum, you must provide:

#### Core Third-Party Services
OpenRSVP relies on a few free external services for database hosting, rate limiting, and storage:

1. **Database (Neon or Supabase):** 
   - Create a free Postgres database at [Neon.tech](https://neon.tech) or Supabase.
   - Copy the connection string and paste it as `DATABASE_URL`.
2. **Rate Limiting (Upstash):**
   - Create a free Redis database at [Upstash](https://upstash.com).
   - Copy the REST URL and Token to `UPSTASH_REDIS_REST_URL` and `UPSTASH_REDIS_REST_TOKEN`.
3. **Authentication Secret:**
   - Generate a random 32-character string and set it as `BETTER_AUTH_SECRET`.
4. **Storage (Images):**
   - Configure your S3 credentials (we recommend free Cloudflare R2 or standard AWS S3).


### 3. Spin up the Containers
Run the following command to build the image and start the web server alongside Caddy:
```bash
docker-compose up -d --build
```

### 4. Initialize the Database
Once the container is running, you must push the Prisma schema to your new database to create the required tables. Run this command to execute the migration inside the container:
```bash
docker-compose exec rsvp-web bunx prisma db push
```

---

## 💻 Local Testing Guide

If you just want to test OpenRSVP locally on your computer without setting up a domain or SSL certificates, we provide a dedicated local compose file.

1. Configure your `.env` file just like above, but leave URLs as `http://localhost:3000`.
2. Start the local stack (which bypasses Caddy and binds directly to port 3000):
```bash
docker-compose -f docker-compose.local.yml up -d --build
```
3. Initialize the database:
```bash
docker-compose -f docker-compose.local.yml exec rsvp-web-local bunx prisma db push
```
4. Open `http://localhost:3000` in your browser.

---

## 🔑 License Keys

OpenRSVP is completely free to self-host. By default, it operates on the **Basic Tier** (1 workspace, 2 events, 50 guests).

To unlock higher limits (Registered Tier) for free, you simply need to generate a License Key:
1. Visit the [OpenRSVP License Validator Hub](https://openrsvp.korex.ovh).
2. Click **Get your Free Key**.
3. Copy the generated key.
4. Log into your self-hosted OpenRSVP instance, go to **Billing**, and paste your key to instantly upgrade your instance.

---

## 🔧 Useful Commands

**View Live Logs:**
```bash
docker-compose logs -f
```

**Restart After Updating `.env`:**
```bash
docker-compose down
docker-compose up -d
```

## License
OpenRSVP is distributed under the terms of the included EULA (`LICENSE.md`). You are permitted to self-host and modify the software for your own events, but circumventing license limits or reselling the software as a service is strictly prohibited.
