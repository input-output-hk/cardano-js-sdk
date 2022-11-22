# Cardano JS SDK | projection

Chain Sync event projection utilities.

## Summary

Projection is based on [RxJS](https://rxjs.dev/), where source observable of Chain Sync events is processed with various [operators](./src/operators/).

There are no restrictions what an operator can do - you can utilize the full power of RxJS which makes it very flexible.

All operators implemented in this package are extending the source event object with extra properties, e.g.

```ts
  chainSync$.pipe(
    withStabilityWindow(dataWithPoolRetirement.genesis),
    tap(({ stabilityWindowSlotsCount }) => console.log('Stability window:', stabilityWindowSlotsCount)),
    withRolledBackEvents(),
    tap((evt) => evt.eventType === ChainSyncEventType.RollBackward && console.log('Rolled back events:', evt.rolledBackEvents)),
  )
```
