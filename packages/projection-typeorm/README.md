# Cardano JS SDK | projection-typeorm

Project Chain Sync events into PostgreSQL via TypeORM.

## Adding new projections

1. Create a new `projection` (a collection of map/reduce-style operators that add some properties onto projection events) and export it from [projections/index](../projection/src/projections/index.ts)
2. Create a new granular TypeORM sink and export it from [sinks/index](./src/sinks/index.ts)

### Demo

See [demo/projection-typeorm.js](../../demo/)
