## [projection-typeorm.js](./projection-typeorm.js)

An example of [projection](../packages/projection/) into PostgreSQL database ([projection-typeorm](../packages/projection-typeorm/)).

### Environment

```sh
cd /path/to/cardano-js-sdk/ # monorepo root
yarn && yarn build
yarn preprod:up cardano-node ogmios postgres # or preview:up/mainnet:up
```

### Configuration

Projection can be customized by adding/removing operators and TypeORM entities, e.g. you may add those operators `Mappers.withStakeKeys(), ..., storeStakeKeys()` alongside with adding a `StakeKeyEntity`.

### Running the script

```sh
node demo/projection-typeorm.js
```

### Recreating the schema

```sh
node demo/projection-typeorm.js --drop
```
