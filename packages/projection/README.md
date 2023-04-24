# Cardano JS SDK | projection

Chain Sync event projection utilities.

## Summary

Projection is based on [RxJS](https://rxjs.dev/), where source observable of Chain Sync events is processed with various [operators](./src/operators/).

There are no restrictions what an operator can do - you can utilize the full power of RxJS which makes it very flexible.

All operators implemented in this package are extending the source event object with extra properties, e.g.

```ts
  Bootstrap.fromCardanoNode({ buffer, cardanoNode, logger }).pipe(
    Mappers.withStakeKeys(),
    tap(({ stakeKeys }) => console.log('stakeKeys', stakeKeys)),
    Mappers.withStakePools(),
    tap(({ stakePools }) => console.log('stakePools', stakePools)),
  )
```
