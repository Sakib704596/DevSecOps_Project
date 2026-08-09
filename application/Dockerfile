# ---------------------------------------------------------------------------
# STAGE 1: "builder" — installs dependencies
# We do this in a separate stage so build tools and dev dependencies don't
# end up bloating the final image that actually runs in production.
# ---------------------------------------------------------------------------
FROM node:22-alpine AS builder

WORKDIR /app

# Copy only the dependency manifests first — NOT the whole app yet.
# This is a deliberate Docker caching trick: if package.json hasn't
# changed, Docker reuses the cached "npm install" layer instead of
# re-running it every build, even if your app code changed.
COPY package.json package-lock.json* ./

RUN npm install --omit=dev

# Now copy the actual application code
COPY . .

# ---------------------------------------------------------------------------
# STAGE 2: "runner" — the actual image that ships and runs
# Starts fresh from a clean, minimal base — none of the build-stage
# leftovers carry over unless we explicitly copy them.
# ---------------------------------------------------------------------------
FROM node:22-alpine AS runner

WORKDIR /app

# Run as a non-root user — a real security practice, not decoration.
# If this container is ever compromised, the attacker doesn't get root.
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copy only what's needed to RUN the app — node_modules and source —
# from the builder stage, not the whole build environment.
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/app.js ./app.js
COPY --from=builder --chown=appuser:appgroup /app/package.json ./package.json

EXPOSE 3000

# Basic container-level health check — Docker (and later Kubernetes)
# can use this to know if the app inside is actually responding,
# not just "the process exists."
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

CMD ["node", "app.js"]
