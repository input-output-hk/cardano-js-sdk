# Cardano JS SDK | projection-typeorm

Project Chain Sync events into PostgreSQL via TypeORM.

## Adding new projections

1. Create a new mapper that maps the block into something that you want to project (see [withStakeKeys](../projection/src/operators/Mappers/certificates/withStakeKeys.ts) as an example).
2. Create a new granular TypeORM store (see [storeStakeKeys](./src/operators/storeStakeKeys.ts)) as an example.

### Demo

See [demo/projection-typeorm.js](../../demo/)
