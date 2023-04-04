## [projection-typeorm.js](./projection-typeorm.js)

An example of [projection](../packages/projection/) into PostgreSQL database ([projection-typeorm](../packages/projection-typeorm/)).

### Environment

```sh
cd /path/to/cardano-js-sdk/ # monorepo root
yarn && yarn build
yarn preprod:up cardano-node-ogmios postgres # or preview:up/mainnet:up
```

### Configuration

Update `projections` variable in the [script](./projection-typeorm.js) to pick your desired set of projections. See available options in [projections/index](../packages/projection/src/projections/index.ts).

### Running the script

```sh
node demo/projection-typeorm.js
```

### Recreating the schema

```sh
node demo/projection-typeorm.js --drop
```
