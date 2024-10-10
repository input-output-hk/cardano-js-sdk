ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION} AS ubuntu-nodejs
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

FROM ubuntu-nodejs AS cardano-services

ARG NETWORK=mainnet
ENV NETWORK=${NETWORK}

RUN \
  curl --proto '=https' --tlsv1.2 -sSf -L https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
  apt-get update && apt-get install yarn -y
COPY packages/cardano-services/config/network/${NETWORK} /config/
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
RUN yarn workspaces focus --all --production

FROM cardano-services AS provider-server
WORKDIR /app/packages/cardano-services
HEALTHCHECK --interval=15s --timeout=15s CMD curl --fail --silent http://0.0.0.0:3000/health | jq '.ok' | awk '{ if ($0 == "true") exit 0; else exit 1}' || exit 1
CMD ["bash", "-c", "../../node_modules/.bin/tsx watch --clear-screen=false --conditions=development src/cli start-provider-server"]

FROM cardano-services AS worker
WORKDIR /app/packages/cardano-services
CMD ["bash", "-c", "../../node_modules/.bin/tsx watch --clear-screen=false --conditions=development src/cli start-pg-boss-worker"]

FROM cardano-services AS blockfrost-worker
ENV \
  API_URL="http://0.0.0.0:3000" \
  BLOCKFROST_API_FILE=/run/secrets/blockfrost_key \
  POSTGRES_DB_FILE_DB_SYNC=/run/secrets/postgres_db_db_sync \
  POSTGRES_HOST_DB_SYNC=postgres \
  POSTGRES_PASSWORD_FILE_DB_SYNC=/run/secrets/postgres_password \
  POSTGRES_PORT_DB_SYNC=5432 \
  POSTGRES_USER_FILE_DB_SYNC=/run/secrets/postgres_user
WORKDIR /app/packages/cardano-services
CMD ["bash", "-c", "../../node_modules/.bin/tsx watch --clear-screen=false --conditions=development src/cli start-blockfrost-worker"]

FROM cardano-services AS pg-boss-worker
WORKDIR /config
COPY compose/schedules.json .
ENV SCHEDULES=/config/schedules.json
WORKDIR /app/packages/cardano-services
HEALTHCHECK CMD curl --fail --silent http://localhost:3003/v1.0.0/health
CMD ["bash", "-c", "../../node_modules/.bin/tsx watch --clear-screen=false --conditions=development src/cli start-pg-boss-worker"]

FROM cardano-services AS projector
WORKDIR /
COPY compose/projector/init.* ./
RUN chmod 755 init.sh
HEALTHCHECK CMD test `curl --fail --silent http://localhost:3000/v1.0.0/health | jq -r ".services[0].projectedTip.blockNo"` -gt 1
CMD ["./init.sh"]

FROM cardano-services AS ws-server
WORKDIR /app/packages/cardano-services
HEALTHCHECK CMD curl --fail --silent http://localhost:3000/v1.0.0/health
CMD ["bash", "-c", "../../node_modules/.bin/tsx watch --clear-screen=false --conditions=development src/cli start-ws-server"]
