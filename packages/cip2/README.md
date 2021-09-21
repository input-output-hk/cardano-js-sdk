# Cardano JS SDK | CIP2 | Input Selection

This package implements concepts from the draft specification being developed in [CIP-0002].

Currently there is only 1 input selection algorithm: RoundRobinRandomImprove, which is a [Random-Improve] adaptation that handles asset selection.

## Usage Example

```typescript
import { roundRobinRandomImprove, InputSelector, SelectionResult } from '@cardano-sdk/cip2';
import { loadCardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { TransactionOutputs, TransactionUnspentOutput } from '@emurgo/cardano-serialization-lib-browser';
import { ProtocolParametersAlonzo } from '@cardano-ogmios/schema';

const demo = async ({ coinsPerUtxoWord }: ProtocolParametersAlonzo): Promise<SelectionResult> => {
  const CSL = await loadCardanoSerializationLib();
  const selector: InputSelector = roundRobinRandomImprove(CSL, coinsPerUtxoWord);
  // It is important that you use the same instance of cardano-serialization-lib across your application.
  // Bad: TransactionUnspentOutput.new(...)
  // Good: CSL.TransactionUnspentOutput.new(...)
  const utxo = [CSL.TransactionUnspentOutput.new(...), ...];
  const outputs = CSL.TransactionOutputs.new(...);

  return selector.select({
    utxo,
    outputs,
    maximumInputCount: availableUtxo.length,
    estimateTxFee: (utxo, outputs, change) => {
      throw new Error("TODO: build the transaction and return a Promise of it's size in bytes.");
    }
  });
};
```

[cip-0002]: https://cips.cardano.org/cips/cip2/
[random-improve]: https://cips.cardano.org/cips/cip2/#randomimprove
