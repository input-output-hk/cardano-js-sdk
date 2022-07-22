# Cardano JS SDK | Cardano GraphQL Services
Libraries and program entrypoints for services to facilitate remote data and submit access using 
[Provider] interfaces over HTTP, with _optional_ queue-based transaction submission; The 
[TxSubmitHttpService] can be configured to submit directly via [Ogmios], or via a [RabbitMQ] broker,
with one or more workers handling submission and response job creation. Data is sourced from 
[Cardano DB Sync], the local [Cardano Node] via [Ogmios] Local State Queries, genesis files, and 
remote sources.

## Features
- [CLI] or run scripts for the [HTTP server](./src/run.ts) and [worker](./src/startWorker.ts) with 
configuration via environment variables and _optional_ loading of secrets from disk.
- Service port discovery via DNS resolution, or static configuration.
- Fault-tolerant transaction submission via persistent queue, or direct submission.
- _Optional_ [Prometheus] metrics available at `/metrics`
- Data sourced from Cardano DB Sync PostgreSQL, Local State Queries, genesis files, and remote 
  sources.

## Services

The services require instances of [Cardano Node] and [Ogmios] as a minimum, with 
[Cardano DB Sync] and [RabbitMQ] dependent on the run command. Please refer to
[docker-compose.json](./docker-compose.yml) for the current supported version of each service 
dependency.

### HTTP Server
The HTTP server can be started with one or more provider modules by name, segmented by URL path. 
Run the [CLI] with `start-server --help` to see the full list of options, or inspect the 
environment variables within [./src/run.ts](./src/run.ts). 

### Worker
A worker must be started when opting for queue-based transaction submission.
Run the [CLI] with `start-worker --help` to see the full list of options, or inspect the
environment variables within [./src/startWorker.ts](./src/startWorker.ts).


## Examples

_The following examples require the [install and build] steps to be completed._

#### All Providers | Static Service Config | Direct Tx Submission

- The server will expose all [Provider] HTTP services
- Transactions will be submitted directly via [Ogmios], running at `ws://localhost:1338`.
- Connects to [PostgreSQL] service running at `localhost:5432`
- HTTP API exposed using a custom API URL

``` console
./dist/cjs/cli.js \
  start-server \
    --api-url http://localhost:6000 \
    --cardano-node-config-path ./config/cardano-node/config.json \
    --ogmios-url  ws://localhost:1338 \
    --db-connection-string postgresql://somePgUser:somePassword@localhost:5432/someDbName \
    asset,chain-history,stake-pool,tx-submit,network-info,utxo
```

#### All Providers | Service Discovery | Queued Tx Submission | Metrics

- The server will expose all [Provider] HTTP services
- Transactions will be queued by the HTTP service, with the worker completing the
  submission. The HTTP service receives the submission result via a dedicated channel to
  complete the HTTP request.
- Ports for [Ogmios], [PostgreSQL], and [RabbitMQ], discovered using DNS resolution.
- HTTP API exposed using a custom API URL
- Prometheus metrics exporter enabled at http://localhost:6000/metrics

``` console
./dist/cjs/cli.js \
  start-server \
    --api-url http://localhost:6000 \
    --cardano-node-config-path ./config/cardano-node/config.json \
    --enable-metrics true \
    --ogmios-srv-service-name  some-domain-for-ogmios \
    --postgres-db someDbName \
    --postgres-password somePassword \
    --postgres-srv-service-name \
    --postgres-user somePgUser \
    --rabbitmq-srv-service-name some-domain-for-rabbitmq \
    --use-queue \
    asset,chain-history,stake-pool,tx-submit,network-info,utxo
```
``` console
./dist/cjs/cli.js \
  start-worker \
    --ogmios-srv-service-name  some-domain-for-ogmios \
    --rabbitmq-srv-service-name some-domain-for-rabbitmq
```

## Tests

See [code coverage report]

[Cardano DB Sync]: https://github.com/input-output-hk/cardano-db-sync
[Cardano Node]: https://github.com/input-output-hk/cardano-node
[code coverage report]: https://input-output-hk.github.io/cardano-js-sdk/coverage/cardano-services
[CLI]: ./src/cli.ts
[Ogmios]: https://ogmios.dev/
[install and build]: ../../README.md#install-and-build
[PostgreSQL]: https://www.postgresql.org/
[Prometheus]: https://prometheus.io/
[Provider]: ../core/src/Provider
[RabbitMQ]: https://www.rabbitmq.com/
[TxSubmitHttpService]: ./src/TxSubmit/TxSubmitHttpService.ts
