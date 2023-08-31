ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION} as ubuntu-nodejs
ARG NODEJS_MAJOR_VERSION=14
ENV DEBIAN_FRONTEND=nonintercative
RUN apt-get update && apt-get install curl -y
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://deb.nodesource.com/setup_${NODEJS_MAJOR_VERSION}.x | bash -
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
  echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get install nodejs -y
RUN apt-get install -y --no-install-recommends ca-certificates jq postgresql-client

FROM ubuntu-nodejs as nodejs-builder
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
  apt-get update && apt-get install pkg-config libusb-1.0 libudev-dev gcc g++ make gnupg2 yarn -y
RUN yarn global add node-gyp@9.0.0
RUN mkdir -p /app/packages
WORKDIR /app
COPY build build
COPY packages packages
COPY scripts scripts
COPY .yarn .yarn
COPY \
  .eslintrc.js \
  .prettierrc \
  .yarnrc.yml \
  complete.eslintrc.js \
  eslint.tsconfig.json \
  package.json \
  tsconfig.json \
  yarn.lock \
  yarn-project.nix \
  /app/

FROM nodejs-builder as cardano-services-builder
RUN yarn --immutable --inline-builds
RUN NODE_OPTIONS=--max_old_space_size=10240 yarn build

FROM nodejs-builder as cardano-services-production-deps
RUN yarn workspaces focus --all --production

FROM ubuntu-nodejs as cardano-services
COPY --from=cardano-services-production-deps /app/node_modules /app/node_modules
COPY --from=cardano-services-production-deps /app/packages/cardano-services/node_modules /app/packages/cardano-services/node_modules
COPY --from=cardano-services-production-deps /app/packages/projection-typeorm/node_modules /app/packages/projection-typeorm/node_modules
COPY --from=cardano-services-builder /app/scripts /app/scripts
COPY --from=cardano-services-builder /app/packages/cardano-services/dist /app/packages/cardano-services/dist
COPY --from=cardano-services-builder /app/packages/cardano-services/package.json /app/packages/cardano-services/package.json
COPY --from=cardano-services-builder /app/packages/cardano-services-client/dist /app/packages/cardano-services-client/dist
COPY --from=cardano-services-builder /app/packages/cardano-services-client/package.json /app/packages/cardano-services-client/package.json
COPY --from=cardano-services-builder /app/packages/core/dist /app/packages/core/dist
COPY --from=cardano-services-builder /app/packages/core/package.json /app/packages/core/package.json
COPY --from=cardano-services-builder /app/packages/crypto/dist /app/packages/crypto/dist
COPY --from=cardano-services-builder /app/packages/crypto/package.json /app/packages/crypto/package.json
COPY --from=cardano-services-builder /app/packages/ogmios/dist /app/packages/ogmios/dist
COPY --from=cardano-services-builder /app/packages/ogmios/package.json /app/packages/ogmios/package.json
COPY --from=cardano-services-builder /app/packages/projection/dist /app/packages/projection/dist
COPY --from=cardano-services-builder /app/packages/projection/package.json /app/packages/projection/package.json
COPY --from=cardano-services-builder /app/packages/projection-typeorm/dist /app/packages/projection-typeorm/dist
COPY --from=cardano-services-builder /app/packages/projection-typeorm/package.json /app/packages/projection-typeorm/package.json
COPY --from=cardano-services-builder /app/packages/util/dist /app/packages/util/dist
COPY --from=cardano-services-builder /app/packages/util/package.json /app/packages/util/package.json
COPY --from=cardano-services-builder /app/packages/util-rxjs/dist /app/packages/util-rxjs/dist
COPY --from=cardano-services-builder /app/packages/util-rxjs/package.json /app/packages/util-rxjs/package.json

FROM cardano-services as provider-server
ARG NETWORK=mainnet
ENV \
  CARDANO_NODE_CONFIG_PATH=/config/cardano-node/config.json \
  NETWORK=${NETWORK}
WORKDIR /app/packages/cardano-services
COPY packages/cardano-services/config/network/${NETWORK} /config/
EXPOSE 3000
HEALTHCHECK --interval=15s --timeout=15s \
  CMD curl --fail --silent -H 'Origin: http://0.0.0.0:3000' http://0.0.0.0:3000/health | jq '.ok' | awk '{ if ($0 == "true") exit 0; else exit 1}'
CMD ["node", "dist/cjs/cli.js", "start-provider-server"]

FROM cardano-services as worker
WORKDIR /app/packages/cardano-services
CMD ["node", "dist/cjs/cli.js", "start-worker"]

FROM cardano-services as blockfrost-worker
ENV \
  API_URL="http://0.0.0.0:3000" \
  BLOCKFROST_API_FILE=/run/secrets/blockfrost_key \
  POSTGRES_DB_FILE_DB_SYNC=/run/secrets/postgres_db_db_sync \
  POSTGRES_HOST_DB_SYNC=postgres \
  POSTGRES_PASSWORD_FILE_DB_SYNC=/run/secrets/postgres_password \
  POSTGRES_PORT_DB_SYNC=5432 \
  POSTGRES_USER_FILE_DB_SYNC=/run/secrets/postgres_user
WORKDIR /app/packages/cardano-services
CMD ["node", "dist/cjs/cli.js", "start-blockfrost-worker"]

FROM cardano-services as pg-boss-worker
WORKDIR /app/packages/cardano-services
CMD ["node", "dist/cjs/cli.js", "start-pg-boss-worker"]

FROM cardano-services as projector
WORKDIR /
COPY compose/projector/init.* ./
RUN chmod 755 init.sh
CMD ["./init.sh"]
