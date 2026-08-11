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

# Remove npm/npx/corepack/yarn from the final image entirely.
# The app only needs `node` to run — these are build-time tools with
# no business being in a production container. This directly removes
# every vulnerability Trivy just found, because all of them lived
# inside npm's own bundled dependencies, not our app's.
RUN rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/bin/npm \
           /usr/local/bin/npx \
           /usr/local/lib/node_modules/corepack \
           /usr/local/bin/corepack \
           /opt/yarn-v1.22.22

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/app.js ./app.js
COPY --from=builder --chown=appuser:appgroup /app/package.json ./package.json

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

CMD ["node", "app.js"]