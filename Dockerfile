################## Optimized ##################

ARG NODE_VERSION="node:16"

FROM $NODE_VERSION as deps
WORKDIR /app
COPY package.json package-lock.json .npmrc ./
RUN npm install

FROM $NODE_VERSION as builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM $NODE_VERSION as runner
ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV
WORKDIR /app
COPY --from=builder --chown=app:app /app/package.json /app/package-lock.json ./
COPY --from=builder --chown=app:app /app/node_modules ./node_modules
COPY --from=builder --chown=app:app /app/public ./public
COPY --from=builder --chown=app:app /app/.next ./.next


EXPOSE 3000

CMD ["npm", "run", "start"]
