# Cardano JS SDK | CIP2 | Input Selection

This package implements concepts from the draft specification being developed in [CIP-0002].

Currently there is only 1 input selection algorithm: RoundRobinRandomImprove, which is a [Random-Improve] adaptation that handles asset selection.

## Usage Example

```typescript
import { roundRobinRandomImprove, InputSelector, SelectionResult, SelectionConstraints } from '@cardano-sdk/cip2';
import { loadCardanoSerializationLib, CSL, CardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { ProtocolParametersAlonzo } from '@cardano-ogmios/schema';

const demo = async ({ coinsPerUtxoWord }: ProtocolParametersAlonzo): Promise<SelectionResult> => {
  const csl: CardanoSerializationLib = await loadCardanoSerializationLib();
  const selector: InputSelector = roundRobinRandomImprove(csl, coinsPerUtxoWord);
  // It is important that you use the same instance of cardano-serialization-lib across your application.
  // Bad: TransactionUnspentOutput.new(...)
  // Good: csl.TransactionUnspentOutput.new(...)
  const utxo: CSL.TransactionUnspentOutput[] = [csl.TransactionUnspentOutput.new(...), ...];
  const outputs: CSL.TransactionOutputs = csl.TransactionOutputs.new(...);
  const constraints: SelectionConstraints = {
    computeMinimumCoinQuantity: (): bigint => coinsPerUtxoWord * 29n,
    tokenBundleSizeExceedsLimit: (tokenBundle: CSL.MultiAsset): boolean =>
      throw new Error('Return true if token bundle is too large'),
    computeMinimumCost: (): Promise<bigint> =>
      throw new Error('Build the transaction and estimate minimum fee'),
    computeSelectionLimit: (): Promise<number> =>
      throw new Error('Compute max number of selected input utxo to not exceed max transaction size'),
  };

  return selector.select({
    utxo,
    outputs,
    constraints,
  });
};
```

## Tests

Input selection is tested with property-based tests using [fast-check], as well as a few regular example-based tests.

See [code coverage report]. Due to nature of property-based tests, code coverage report is slightly different on each build.

RoundRobinRandomImprove has 100% code coverage when using high `numRuns` option (e.g. 100_000).

Note that to run it with high `numRuns` you need to increase _Jest_ and _fast-check_ timeout.

[cip-0002]: https://cips.cardano.org/cips/cip2/
[random-improve]: https://cips.cardano.org/cips/cip2/#randomimprove
[fast-check]: https://github.com/dubzzz/fast-check
[code coverage report]: https://input-output-hk.github.io/cardano-js-sdk/coverage/cip2
