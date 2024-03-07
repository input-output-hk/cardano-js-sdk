# Cardano JS SDK | Cardano GraphQL Services

Libraries and program entrypoints for services to facilitate remote data and submit access using
[Provider] interfaces over HTTP; The [TxSubmitHttpService] can be configured to submit via [Ogmios]
or via [submit-api]. Data is sourced from
[Cardano DB Sync], the local [Cardano Node] via [Ogmios] Local State Queries, genesis files, and
remote sources.

## Features

- [CLI] with configuration via command line arguments or environment variables and _optional_ loading of secrets from disk.
- Service port discovery via DNS resolution, or static configuration.
- Fault-tolerant transaction submission.
- _Optional_ [Prometheus] metrics available at `/metrics`
- Data sourced from Cardano DB Sync PostgreSQL, Local State Queries, genesis files, and remote
  sources.

## Services

The services require instances of [Cardano Node] and [Ogmios] as a minimum, with
[Cardano DB Sync] dependent on the run command. Please refer to
[docker-compose.json](./docker-compose.yml) for the current supported version of each service
dependency.

### Provider Server

The Provider server can be started with one or more services by name, segmented by URL path.
Run the [CLI] with `start-provider-server --help` to see the full list of options.

## Examples

_The following examples require the [install and build] steps to be completed._

#### All Providers | Static Service Config | Direct Tx Submission

- The server will expose all [Provider] HTTP services
- Transactions will be submitted directly via [Ogmios], running at `ws://localhost:1338`.
- Connects to [PostgreSQL] service running at `localhost:5432`
- HTTP API exposed using a custom API URL

**`start-provider-server` using CLI options:**

```bash
./dist/cjs/cli.js \
  start-provider-server \
    --api-url http://localhost:6000 \
    --cardano-node-config-path ./config/network/preprod/cardano-node/config.json \
    --postgres-connection-string-db-sync postgresql://somePgUser:somePassword@localhost:5432/someDbName \
    --ogmios-url  ws://localhost:1338 \
    asset chain-history stake-pool tx-submit network-info utxo rewards
```

**`start-provider-server` using env variables:**

```bash
SERVICE_NAMES=asset,chain-history,stake-pool,tx-submit,network-info,utxo,rewards \
API_URL=http://localhost:6000 \
CARDANO_NODE_CONFIG_PATH=./config/network/preprod/cardano-node/config.json \
POSTGRES_CONNECTION_STRING_DB_SYNC=postgresql://somePgUser:somePassword@localhost:5432/someDbName \
OGMIOS_URL=ws://localhost:1338 \
./dist/cjs/cli.js start-provider-server
```

#### All Providers | Service Discovery | Metrics

- The server will expose all [Provider] HTTP services
- Ports for [Ogmios] and [PostgreSQL], discovered using DNS resolution.
- HTTP API exposed using a custom API URL
- Prometheus metrics exporter enabled at http://localhost:6000/metrics

**`start-provider-server` using CLI options:**

```bash
./dist/cjs/cli.js \
  start-provider-server \
    --api-url http://localhost:6000 \
    --enable-metrics \
    --cardano-node-config-path ./config/network/preprod/cardano-node/config.json \
    --postgres-srv-service-name-db-sync someHostName \
    --postgres-db-db-sync someDbName \
    --postgres-user-db-sync somePgUser \
    --postgres-password-db-sync somePassword \
    --ogmios-srv-service-name  some-domain-for-ogmios \
    asset chain-history stake-pool tx-submit network-info utxo rewards
```

**`start-provider-server` using env variables:**

```bash
SERVICE_NAMES=asset,chain-history,stake-pool,tx-submit,network-info,utxo,rewards \
API_URL=http://localhost:6000 \
ENABLE_METRICS=true \
CARDANO_NODE_CONFIG_PATH=./config/network/preprod/cardano-node/config.json \
POSTGRES_SRV_SERVICE_NAME_DB_SYNC=some-domain-for-postgres-db
POSTGRES_DB_DB_SYNC=someDbName \
POSTGRES_USER_DB_SYNC=someUser \
POSTGRES_PASSWORD_DB_SYNC=somePassword \
OGMIOS_SRV_SERVICE_NAME=some-domain-for-ogmios \
./dist/cjs/cli.js start-provider-server
```

**`start-worker` using CLI options:**

```bash
./dist/cjs/cli.js \
  start-worker \
    --ogmios-srv-service-name  some-domain-for-ogmios
```

**`start-worker` using env variables:**

```bash
OGMIOS_SRV_SERVICE_NAME=some-domain-for-ogmios \
./dist/cjs/cli.js start-worker
```

**`start-projector` using CLI options with Ogmios and PostgreSQL running on localhost:**

```bash
./dist/cjs/cli.js \
  start-projector \
    --ogmios-url 'ws://localhost:1339' \
    --postgres-connection-string 'postgresql://postgres:doNoUseThisSecret!@localhost/projection' \
    stake-pool,stake-pool-metadata-job
```

## Production

The _Docker images_ produced by the SDK and the _docker compose infrastructures_ (_mainnet_, _preprod_ and _local-network_) it includes are ready to be used in
production environment.

**Note:** the _docker compose infrastructures_ included in the SDK are mainly used for development purposes: to use
them in production environments, the projector service(s) must be instructed to run the _migration scripts_ rather than
to use the `synchronize` development option from **TypeORM**. This can be achieved through environment variables:

```
SYNCHRONIZE=false yarn preprod:up
```

## Development

To speed up the development process, developers can ignore the migrations while developing or debugging changes.
This freedom is granted by the `synchronize` development option from **TypeORM**, which is enabled by default in the
_docker compose infrastructures_ included in the SDK.

### Generating Projector Schema Migrations

In order to grant to the projection service the ability to choose which projections it needs to activate, **the
migrations must be scoped to a single model**: if a single change has impact on more models, one migration for each
impacted model must be generated.

_Hint:_ isolating all the changes to each model in distinct commits can be so helpful for this target!

For each migration, once the change is _finalized_ (all the new entities are added to the `entities` object at
`src/Projection/prepareTypeormProjection.ts`, apart from last minor refinements the PR is approved, etc...), the
relative migration can be generated following these steps.

_Hint:_ if previous hint was followed, to checkout each commit which requires a migration to produce a _fixup_ commit
for each of them can be an easy way to iterate over all the impacted models.

1. Start a new fresh database with `DROP_PROJECTOR_SCHEMA=true SYNCHRONIZE=false yarn preprod up`
   - **Note:** do not override `PROJECTION_NAMES` since in this scope all the projections must be loaded
   - **Note:** this will not apply the current changes to the models into the database schema, so the currently
     developed feature may not work properly, this is not relevant for the target of creating the migration
   - `DROP_PROJECTOR_SCHEMA=true` is used to let the projection service to create the database schema from scratch
   - with `SYNCHRONIZE=false` the projection service runs all migrations rather than reflecting the changes to the
     models on the schema (through the `synchronize` development option from **TypeORM**)
2. Run `yarn generate-migration` to produce a new migration in
   `src/Projections/migrations` directory
   - this compares the database schema against all the models (repeat: only one of them should be changed) and
     generates the required migration
3. Inspect the generated migration
   - **Check:** if the migration has impact on more than one table, the changes was not isolated per model!
     (the change must be reworked)
4. Add the `static entity` property to the migration `class` (to see other migrations for reference)
5. Rename the newly generated migration file and `class` giving them mnemonic names
6. Export the new migration from `migrations` array at `src/Projections/migrations/index.ts`

## Tests

See [code coverage report]

[cardano db sync]: https://github.com/IntersectMBO/cardano-db-sync
[cardano node]: https://github.com/IntersectMBO/cardano-node
[cli]: ./src/cli.ts
[code coverage report]: https://input-output-hk.github.io/cardano-js-sdk/coverage/cardano-services
[install and build]: ../../README.md#install-and-build
[ogmios]: https://ogmios.dev/
[postgresql]: https://www.postgresql.org/
[prometheus]: https://prometheus.io/
[provider]: ../core/src/Provider
[submit-api]: https://github.com/IntersectMBO/cardano-node/tree/master/cardano-submit-api
[txsubmithttpservice]: ./src/TxSubmit/TxSubmitHttpService.ts
