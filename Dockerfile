FROM oven/bun:1-alpine AS base
WORKDIR /app

# Stage 1: Dependencies
FROM base AS deps
COPY package.json bun.lock ./
# Ignore scripts to prevent Prisma generate from running before Prisma is available
RUN bun install --frozen-lockfile --ignore-scripts

# Stage 2: Builder
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Generate Prisma Client
RUN bunx prisma generate
# Build the Next.js standalone application
RUN bun run build

# Stage 3: Runner
FROM base AS runner
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Install prisma to run db push at runtime
RUN bun add prisma

# Create a non-root user for security
RUN addgroup --system --gid 1001 bunjs && \
    adduser --system --uid 1001 nextjs

# Copy the standalone build and static files
COPY --from=builder /app/public ./public
# Copy next standalone files
COPY --from=builder --chown=nextjs:bunjs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:bunjs /app/.next/static ./.next/static

# Copy Prisma schema so users can run `bunx prisma db push` inside the container
COPY --from=builder --chown=nextjs:bunjs /app/prisma ./prisma
COPY --from=builder --chown=nextjs:bunjs /app/prisma.config.ts ./

# Add entrypoint script
COPY --chown=nextjs:bunjs docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER nextjs
EXPOSE 3000

# Run entrypoint to push database before starting server
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# The standalone output generates a server.js file
CMD ["bun", "server.js"]
