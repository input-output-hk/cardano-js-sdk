ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION} as ubuntu-nodejs
ARG NODEJS_MAJOR_VERSION=14
ENV DEBIAN_FRONTEND=nonintercative
RUN apt-get update && apt-get install curl -y &&\
  curl --proto '=https' --tlsv1.2 -sSf -L https://deb.nodesource.com/setup_${NODEJS_MAJOR_VERSION}.x | bash - &&\
  apt-get install nodejs -y

FROM ubuntu-nodejs as nodejs-builder
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
  apt-get update && apt-get install gcc g++ make gnupg2 yarn -y
RUN mkdir -p /app/packages
WORKDIR /app
COPY build build
COPY packages packages
COPY scripts scripts
COPY \
  package.json \
  tsconfig.json \
  yarn.lock \
  /app/

FROM nodejs-builder as cardano-services-builder
RUN yarn --frozen-lockfile --non-interactive &&\
  yarn build

FROM nodejs-builder as cardano-services-production-deps
RUN yarn --frozen-lockfile --non-interactive --production

FROM ubuntu-nodejs as cardano-services
COPY --from=cardano-services-production-deps /app/node_modules /app/node_modules
COPY --from=cardano-services-builder /app/packages/cardano-services/dist /app/packages/cardano-services/dist
COPY --from=cardano-services-production-deps /app/packages/cardano-services/node_modules /app/packages/cardano-services/node_modules
COPY --from=cardano-services-builder /app/scripts /app/scripts
COPY --from=cardano-services-builder /app/packages/cardano-services/package.json /app/packages/cardano-services/package.json
COPY --from=cardano-services-builder /app/packages/core/dist /app/packages/core/dist
COPY --from=cardano-services-builder /app/packages/core/package.json /app/packages/core/package.json
COPY --from=cardano-services-builder /app/packages/ogmios/dist /app/packages/ogmios/dist
COPY --from=cardano-services-builder /app/packages/ogmios/package.json /app/packages/ogmios/package.json
COPY --from=cardano-services-builder /app/packages/rabbitmq/dist /app/packages/rabbitmq/dist
COPY --from=cardano-services-builder /app/packages/rabbitmq/package.json /app/packages/rabbitmq/package.json
COPY --from=cardano-services-builder /app/packages/util/dist /app/packages/util/dist
COPY --from=cardano-services-builder /app/packages/util/package.json /app/packages/util/package.json

FROM cardano-services as http-server
ARG NETWORK=mainnet
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
  echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list &&\
  apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates
ENV \
  API_URL="http://0.0.0.0:3000" \
  CARDANO_NODE_CONFIG_PATH=/config/cardano-node/config.json \
  NETWORK=${NETWORK} \
  OGMIOS_URL="ws://cardano-node-ogmios:1337" \
  POSTGRES_DB_FILE=/run/secrets/postgres_db \
  POSTGRES_HOST=postgres \
  POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password \
  POSTGRES_PORT=5432 \
  POSTGRES_USER_FILE=/run/secrets/postgres_user \
  SERVICE_NAMES="chain-history,network-info,rewards,stake-pool,tx-submit,utxo"
WORKDIR /app/packages/cardano-services
COPY packages/cardano-services/config/network/${NETWORK} /config/
EXPOSE 3000
CMD ["node", "dist/cjs/run.js"]

FROM cardano-services as worker
ENV \
  OGMIOS_URL="ws://cardano-node-ogmios:1337" \
  RABBITMQ_URL='amqp://rabbitmq:5672'
WORKDIR /app/packages/cardano-services
CMD ["node", "dist/cjs/startWorker.js"]
