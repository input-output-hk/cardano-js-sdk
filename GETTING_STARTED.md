# Getting started

This is a guide on how to quickly start using the SDK to build your idea, so it is more a guide for clients of the SDK
rather than for contributors to the SDK, although anyone can benefit from it.

> **Warning**
>
> - The steps below are only suitable for development environments.
> - Postgres username and password are [placeholders](./packages/cardano-services/placeholder-secrets) and should be changed.

## Project Overview

The project is divided into two main parts:

1. [cardano-services](./packages/cardano-services/README.md) consists of several backend applications:

   - _Provider server_: a REST API server that can query Cardano data and submit transactions.
   - _Projector_: chain follower that projects blocks into PostgreSQL database.

1. Libraries meant to help with concepts like: key management, cryptography high level helpers, input selection, and many more.
   Two important libraries worth mentioning are:
   - [wallet](./packages/wallet/README.md): provides an opinionated, ready-to-use light wallet abstraction. It uses pretty much all of the
     other client libraries.
   - [web-extension](./packages/web-extension/README.md): has the ingredients to build your idea as a web extension.

## Starting the Provider Services on Preprod testnet

This section covers how to get `cardano-services` started on the `preprod` testnet, and begin building your idea or just explore.

Starting `mainnet` or `preview` is a more advanced topic, and is discouraged in the 'Getting Started' phase as it requires additional settings.

### Prerequisites:

1. Docker compose V2 or later
1. `cardano-js-sdk` project is cloned locally. No need to install or build.
1. An x86-64 machine. It will not work on an ARM computer (like Apple M1 chips). This guide is tested on Ubuntu.

### Option1: `docker compose`:

- This option uses `docker compose` to start the bare minimum services.
- Start Preprod network services:

```bash
$ ./scripts/preprod-network.sh up
```

- Stop Preprod network services:

```bash
$ ./scripts/preprod-network.sh down
```

- Dump the rendered docker compose file:

```bash
$ ./scripts/preprod-network.sh dump
```

### Option2: using `yarn`:

If you are already comfortable with yarn, and have gone through the [System Requirements](./README.md#system-requirements), you can run
one of the commands defined in [cardano-services package.json](./packages/cardano-services/package.json),

```bash
# Start preprod network services
yarn preprod:up -d
```

```bash
# Stop preprod network services
yarn preprod:down
```

## Next steps

1. Wait for all services to be healthy.
1. Each provider from `cardano-services` has an openApi spec describing the REST interface. For example:
   - [NetworkInfo provider OpenAPI spec](./packages/cardano-services/src/NetworkInfo/openApi.json)
1. More advanced examples of using the SDK are in the [e2e tests](./packages/e2e/test/wallet).
   Explore these examples on how to use the wallet and the client libraries.
1. For hardware wallet testing, see [Hardware Testing Guide](./packages/wallet/HARDWARE_TESTING.md).
