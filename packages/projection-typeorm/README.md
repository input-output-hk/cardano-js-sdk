# Cardano JS SDK | projection-typeorm

Project Chain Sync events into PostgreSQL via TypeORM.

## Adding new projections

1. Create a new operator that maps the block into something
2. Create a new granular TypeORM store and export it from [src/operators/index](./src/operators/index.ts)

### Demo

See [demo/projection-typeorm.js](../../demo/)
