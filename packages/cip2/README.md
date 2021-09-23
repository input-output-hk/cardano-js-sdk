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

[cip-0002]: https://cips.cardano.org/cips/cip2/
[random-improve]: https://cips.cardano.org/cips/cip2/#randomimprove
