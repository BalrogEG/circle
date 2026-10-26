FROM node:22-alpine AS build
WORKDIR /app
ENV HUSKY=0 NEXT_TELEMETRY_DISABLED=1
RUN npm install -g pnpm@9.15.9
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
# Font fallback for the stubbed next/font variables (see app/layout.tsx in this fork).
RUN sed -i "s/var(--font-geist-sans)/var(--font-geist-sans, ui-sans-serif, system-ui, sans-serif)/; s/var(--font-geist-mono)/var(--font-geist-mono, ui-monospace, monospace)/" app/globals.css && pnpm build

FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 PORT=3000 HOSTNAME=0.0.0.0
COPY --from=build --chown=node:node /app/package.json ./package.json
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/.next ./.next
COPY --from=build --chown=node:node /app/public ./public
COPY --from=build --chown=node:node /app/next.config.ts ./next.config.ts
USER node
EXPOSE 3000
CMD ["node_modules/.bin/next", "start", "-p", "3000"]
