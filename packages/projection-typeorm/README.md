# Cardano JS SDK | projection-typeorm

This package is a library of utilities for projecting `ProjectionEvent`s into PostgreSQL database via [TypeORM](https://github.com/typeorm/typeorm).

If you're interested in generic projection types and utilities, see [projection](../projection) package.

If you're interested in projector application as run by Lace, see [setup](../cardano-services/src/Projection) and [README](../cardano-services/README.md) in `cardano-services` package.

## TypeormStabilityWindowBuffer

Writes the block data into [block_data](./src/entity/BlockData.entity.ts) table and implements [StabilityWindowBuffer](../projection/README.md#stabilitywindowbuffer) interface that is required by [Bootstrap.fromCardanoNode](../projection/README.md#bootstrapfromcardanonode)

### TypeormStabilityWindowBuffer.storeBlockData

This method is intended to be called as part of PostgreSQL transaction that writes all other data from the event. It is important to keep StabilityWindowBuffer consistent with  projection state.

## createTypeormTipTracker

Queries and emits local tip (latest block header) from [block](./src/entity/Block.entity.ts) table. Returns:
- an operator that should be applied after processing the block
- an `Observable<TipOrOrgin>` that is required by [Bootstrap.fromCardanoNode](../projection/README.md#bootstrapfromcardanonode)

## withTypeormTransaction

Adds TypeORM context (query runner) to each event and starts a PostgreSQL transaction. Subsequent operators can utilize this context to perform database operations (see [Store Operators](#store-operators)).

## typeormTransactionCommit

Commits PostgreSQL transaction started by [withTypeormTransaction](#withtypeormtransaction) and removes TypeORM context from the event object.

## createObservableConnection

Utility to initialize TypeORM data source.
Returns an Observable that can be used as a dependency for
[withTypeormTransaction](#withtypeormtransaction), [TypeormStabilityWindowBuffer](#typeormstabilitywindowbuffer) and [createTypeormTipTracker](#createtypeormtiptracker).

## Store Operators

[Each store operator](./src/operators) takes in an `Observable<WithTypeormContext & T>`, where `T` depends on what the specific operator needs. Usually it depends on one or more of the [Mappers](../projection/README.md#mappers).

Most store operators will just write some data into the database and emit the same event object (unchanged). However, they can also add additional context to the events (see [storeAssets](./src/operators/storeAssets.ts) which adds new total supplies for each minted asset).

---

### Adding New Store Operators

1. (optional) Create a new mapper that maps the block into something that you want to project (see [withStakeKeys](../projection/src/operators/Mappers/certificates/withStakeKeys.ts) as an example).
2. Create a new granular TypeORM store (see [storeStakeKeys](./src/operators/storeStakeKeys.ts)) as an example.
