## Blockfrost hybrid cache e2e test

This test compare the result of the same API calls which, internally, perform different queries.

In order to run it a synced _preprod_ instance is required launched as follows:

### Starting docker compose

```bash
POSTGRES_PORT=5435 OGMIOS_PORT=1340 yarn preprod:up
```

`POSTGRES_PORT` and `OGMIOS_PORT` must actually match the ones in `DB_SYNC_CONNECTION_STRING` and
`OGMIOS_URL` from `.env` file.

#### Lack of migration plan

To make this solution faster no DB schema migration plan will be present.
To handle changes in the DB schema (expected to happen only during the initial development stage)
the _preprod_ instance must be shut down and restarted with `DROP_SCHEMA=true`.

### Running the test

To run the test, issue following command:

```bash
NETWORK=target yarn test:blockfrost
```

Since it starts two provider servers it is required to provide it the target network in order to
let them to load the right cardano node configuration file.

In case of problems the stack trace can be useful to address them; once the test run correctly,
following command makes the output more clean.

```bash
NETWORK=target yarn test:blockfrost --noStackTrace
```
