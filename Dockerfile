ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION} as ubuntu-nodejs
ARG NODEJS_MAJOR_VERSION=18
ENV DEBIAN_FRONTEND=nonintercative

RUN \
  apt-get update &&\
  apt-get install ca-certificates curl gnupg lsb-release -y &&\
  mkdir -p /etc/apt/keyrings &&\
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg &&\
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODEJS_MAJOR_VERSION.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list &&\
  curl --proto '=https' --tlsv1.2 -sSf -L https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
  echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list &&\
  apt-get update &&\
  apt-get install nodejs -y &&\
  apt-get install -y --no-install-recommends ca-certificates jq postgresql-client

FROM ubuntu-nodejs as nodejs-builder
RUN \
  curl --proto '=https' --tlsv1.2 -sSf -L https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
  apt-get update && apt-get install yarn -y
WORKDIR /app
COPY build build
COPY packages/cardano-services/package.json packages/cardano-services/package.json
COPY packages/cardano-services-client/package.json packages/cardano-services-client/package.json
COPY packages/core/package.json packages/core/package.json
COPY packages/crypto/package.json packages/crypto/package.json
COPY packages/dapp-connector/package.json packages/dapp-connector/package.json
COPY packages/e2e/package.json packages/e2e/package.json
COPY packages/golden-test-generator/package.json packages/golden-test-generator/package.json
COPY packages/governance/package.json packages/governance/package.json
COPY packages/hardware-ledger/package.json packages/hardware-ledger/package.json
COPY packages/hardware-trezor/package.json packages/hardware-trezor/package.json
COPY packages/input-selection/package.json packages/input-selection/package.json
COPY packages/key-management/package.json packages/key-management/package.json
COPY packages/ogmios/package.json packages/ogmios/package.json
COPY packages/projection/package.json packages/projection/package.json
COPY packages/projection-typeorm/package.json packages/projection-typeorm/package.json
COPY packages/tx-construction/package.json packages/tx-construction/package.json
COPY packages/util/package.json packages/util/package.json
COPY packages/util-dev/package.json packages/util-dev/package.json
COPY packages/util-rxjs/package.json packages/util-rxjs/package.json
COPY packages/wallet/package.json packages/wallet/package.json
COPY packages/web-extension/package.json packages/web-extension/package.json
COPY scripts scripts
COPY .yarn .yarn
COPY .eslintrc.js .prettierrc .yarnrc.yml complete.eslintrc.js eslint.tsconfig.json package.json tsconfig.json yarn.lock yarn-project.nix ./

FROM nodejs-builder as cardano-services-builder
# NOTE: Pay attention to --mode=skip-build
# For details: https://github.com/input-output-hk/cardano-js-sdk/pull/1024
RUN yarn --immutable --inline-builds --mode=skip-build
COPY packages packages
RUN \
  echo "export const unused = 'unused';" > packages/e2e/src/index.ts &&\
  NODE_OPTIONS=--max_old_space_size=10240 yarn build:cjs

FROM nodejs-builder as cardano-services-production-deps
RUN yarn workspaces focus --all --production

FROM ubuntu-nodejs as cardano-services
COPY --from=cardano-services-production-deps /app/node_modules /app/node_modules
COPY --from=cardano-services-production-deps /app/packages/cardano-services/node_modules /app/packages/cardano-services/node_modules
COPY --from=cardano-services-production-deps /app/packages/core/node_modules /app/packages/core/node_modules
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
WORKDIR /config
COPY compose/schedules.json .
ENV SCHEDULES=/config/schedules.json
WORKDIR /app/packages/cardano-services
HEALTHCHECK CMD curl -s --fail http://localhost:3003/v1.0.0/health
CMD ["node", "dist/cjs/cli.js", "start-pg-boss-worker"]

FROM cardano-services as projector
WORKDIR /
COPY compose/projector/init.* ./
RUN chmod 755 init.sh
HEALTHCHECK CMD test `curl -fs http://localhost:3000/v1.0.0/health | jq -r ".services[0].projectedTip.blockNo"` -gt 1
CMD ["./init.sh"]
