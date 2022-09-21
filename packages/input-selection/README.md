# Cardano JS SDK | Input Selection | CIP-0002

This package implements concepts from the draft specification being developed in [CIP-0002].

Currently, there is only 1 input selection algorithm: RoundRobinRandomImprove, which is an [Random-Improve] adaptation that handles asset selection.

## Usage Example

```typescript
import { roundRobinRandomImprove, defaultSelectionConstraints, InputSelector, SelectionResult, SelectionSkeleton } from '@cardano-sdk/input-selection';
import { loadCardanoSerializationLib, CSL, CardanoSerializationLib, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';

const demo = async (protocolParameters: ProtocolParametersRequiredByWallet): Promise<SelectionResult> => {
  const csl: CardanoSerializationLib = await loadCardanoSerializationLib();
  const selector: InputSelector = roundRobinRandomImprove(coinsPerUtxoWord);
  // It is important that you use the same instance of cardano-serialization-lib across your application.
  // Bad: TransactionUnspentOutput.new(...)
  // Good: CSL.TransactionUnspentOutput.new(...)
  const utxo: CSL.TransactionUnspentOutput[] = [CSL.TransactionUnspentOutput.new(...), ...];
  const outputs: CSL.TransactionOutput[] = [CSL.TransactionOutput.new(...), ...];
  // Used to estimate min fee and validate transaction size
  const buildTx = (inputSelection: SelectionSkeleton): Promise<CSL.Transaction> => {...};
  const constraints = defaultSelectionConstraints({
    protocolParameters, buildTx,
  });

  return selector.select({
    utxo,
    outputs,
    constraints,
  });
};
```

## Tests

Input selection is tested with property-based tests using [fast-check], as well as a few regular example-based tests.

Due to nature of property-based tests, code coverage report is slightly different on each build.

RoundRobinRandomImprove has 100% code coverage when using high `numRuns` option (e.g. 100_000).

Note that to run it with high `numRuns` you need to increase _Jest_ and _fast-check_ timeout.

See [code coverage report].

[cip-0002]: https://cips.cardano.org/cips/cip2/
[random-improve]: https://cips.cardano.org/cips/cip2/#randomimprove
[fast-check]: https://github.com/dubzzz/fast-check
[code coverage report]: https://input-output-hk.github.io/cardano-js-sdk/coverage/cip2
