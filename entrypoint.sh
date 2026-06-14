#!/bin/sh
set -e

echo "Applying database schema..."
bunx prisma db push --accept-data-loss

echo "Starting Next.js..."
exec "$@"
