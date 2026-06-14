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

#### Core Configuration
OpenRSVP runs its database entirely locally via Docker, but requires a few external services for storage and dispatch:

1. **Database (Local Postgres & Redis):** 
   - The Docker compose file automatically provisions local PostgreSQL and Redis containers, optimized for low-resource environments (e.g. 1-2GB RAM VPS).
   - The `.env.example` already contains the correct `DATABASE_URL` and `REDIS_URL` to connect to these local containers natively. No manual database setup required!
2. **Authentication Secret:**
   - Generate a random 32-character string and set it as `BETTER_AUTH_SECRET`.
3. **Storage (Images):**
   - Configure your S3 credentials (we recommend free Cloudflare R2 or standard AWS S3).


### 3. Spin up the Containers
Run the following command to build the image and start the web server alongside Caddy:
```bash
docker-compose up -d --build
```
> **Note:** The application container will automatically push the Prisma schema and initialize the database tables on startup. No manual migration is needed!

---

## 💻 Local Testing Guide

If you just want to test OpenRSVP locally on your computer without setting up a domain or SSL certificates, we provide a dedicated local compose file.

1. Configure your `.env` file just like above, but leave URLs as `http://localhost:3000`.
2. Start the local stack (which bypasses Caddy and binds directly to port 3000):
```bash
docker-compose -f docker-compose.local.yml up -d --build
```
> **Note:** The local container will automatically initialize the database on startup.

3. Open `http://localhost:3000` in your browser.

---

## 🛠️ Management UIs (Database & Cache)

The Docker setup includes two lightweight UIs for managing your local database and cache.

### Local Access
If you are running the `docker-compose.local.yml` file on your local machine, you can access them directly via your browser:
- **Adminer (PostgreSQL UI):** Open `http://localhost:8080`.
  - **System:** PostgreSQL
  - **Server:** `postgres`
  - **Username:** `user`
  - **Password:** `password`
  - **Database:** `rsvp`
- **Redis Commander (Redis UI):** Open `http://localhost:8081`. 

### Production Access (VPS)
If you are deploying on a VPS, these ports (`8080` and `8081`) are NOT exposed publicly by default for security reasons.

To access them securely over the internet, you should configure **Subdomains** via the Caddy reverse proxy:

1. Create A-Records for two subdomains (e.g. `db.yourdomain.com` and `redis.yourdomain.com`) pointing to your server's IP address.
2. Open the `Caddyfile` and uncomment the subdomain configuration blocks.
3. Replace the placeholder domains with your actual subdomains:
   ```caddyfile
   db.yourdomain.com {
       reverse_proxy adminer:8080
   }

   redis.yourdomain.com {
       reverse_proxy redis-commander:8081
   }
   ```
4. Restart Caddy to apply the changes and auto-provision SSL certificates:
   ```bash
   docker compose down
   docker compose up -d
   ```
5. You can now access Adminer and Redis Commander securely via `https://db.yourdomain.com` and `https://redis.yourdomain.com`.

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
