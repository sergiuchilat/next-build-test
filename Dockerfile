################## Optimized ##################

ARG NODE_VERSION="node:18"

FROM $NODE_VERSION as deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install

FROM $NODE_VERSION as builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
RUN echo "NODE_ENV=production" > .env \
    echo "TEST_PUBLIC_VALUE=${TEST_PUBLIC_VALUE}" >> .env \
    echo "TEST_SECRET_VALUE=${TEST_SECRET_VALUE}" >> .env

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
