FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci --no-audit --no-fund; else npm install --no-audit --no-fund; fi

# Build the app
COPY . ./
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

# Runtime config
ENV NODE_ENV=production
ENV PORT=20128
ENV HOSTNAME=0.0.0.0

# Fix permissions for data directory
RUN mkdir -p /app/data && \
    printf '#!/bin/sh\nchown -R node:node /app/data 2>/dev/null; exec su-exec node "$@"\n' > /entrypoint.sh && \
    chmod +x /entrypoint.sh && \
    apk add --no-cache su-exec

EXPOSE 20128

ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "server.js"]
