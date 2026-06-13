# VPS Docker Deployment Guide

This directory contains everything you need to deploy the RSVP Micro-SaaS to a VPS (Virtual Private Server) like DigitalOcean, Hetzner, or AWS EC2 using Docker Compose.

The deployment uses a **multi-stage build** with `output: "standalone"` to keep the image extremely minimal (avoiding `node_modules` bloat). It also includes **Caddy**, which automatically provisions free SSL certificates via Let's Encrypt and acts as a reverse proxy.

## Prerequisites
1. A Linux VPS with port 80 and 443 open.
2. [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/) installed.
3. A domain name pointed to your VPS's IP address (A Record).

## Setup Instructions

### 1. Configure Caddy (Domain Name)
Open `Caddyfile` and replace `yourdomain.com` with your actual domain.
```caddyfile
rsvp.example.com {
    reverse_proxy rsvp-web:3000
}
```

### 2. Configure Environment Variables
Inside this `docker` folder, open the `.env` file (which is a copy of `.env.example`).
Fill in all the required credentials (Database, BetterAuth Secret, Upstash, Plunk, etc.).

*Important:* Make sure `NEXT_PUBLIC_APP_URL`, `NEXT_PUBLIC_SITE_URL`, and `BETTER_AUTH_URL` match the domain you set in your `Caddyfile` (including `https://`).

### 3. Deploy the Stack
Run the following command from inside this `docker/` directory to build the ultra-minimal standalone Next.js image and start Caddy:

```bash
docker compose up -d --build
```

### 4. Database Migrations
You can easily sync the Prisma schema and run migrations directly inside the running container without needing to install anything on your local host machine. Simply run:

```bash
docker compose exec rsvp-web bunx prisma db push --accept-data-loss
```

## Useful Commands

**View Logs:**
```bash
docker compose logs -f
```

**Restart the App (After updating .env):**
```bash
docker compose down
docker compose up -d
```

**Rebuild the App (After pulling new code):**
```bash
docker compose up -d --build rsvp-web
```
