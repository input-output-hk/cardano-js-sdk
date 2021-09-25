import { roundRobinRandomImprove } from '../src/RoundRobinRandomImprove';
import {
  assertInputSelectionProperties,
  assertFailureProperties,
  createCslTestUtils,
  generateSelectionParams,
  NO_CONSTRAINTS,
  PXL_Asset,
  testInputSelectionFailureMode,
  toConstraints,
  TSLA_Asset,
  testInputSelectionProperties
} from './util';
import { InputSelectionError, InputSelectionFailure } from '../src/InputSelectionError';
import { loadCardanoSerializationLib, CardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import fc from 'fast-check';

const getRoundRobinRandomImprove = (csl: CardanoSerializationLib) => roundRobinRandomImprove(csl);

describe('RoundRobinRandomImprove', () => {
  describe('Examples', () => {
    describe('Properties', () => {
      it('No change', async () => {
        await testInputSelectionProperties({
          getAlgorithm: getRoundRobinRandomImprove,
          createUtxo: (utils) => [utils.createUnspentTxOutput({ coins: 3_000_000n, assets: {} })],
          createOutputs: (utils) => [utils.createOutput({ coins: 3_000_000n, assets: {} })],
          mockConstraints: NO_CONSTRAINTS
        });
      });
    });
    describe('Failure Modes', () => {
      describe('UtxoBalanceInsufficient', () => {
        it('Coin (Outputs>UTxO)', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: (utils) => [
              utils.createUnspentTxOutput({ coins: 3_000_000n, assets: {} }),
              utils.createUnspentTxOutput({ coins: 10_000_000n, assets: {} })
            ],
            createOutputs: (utils) => [
              utils.createOutput({ coins: 12_000_000n, assets: {} }),
              utils.createOutput({ coins: 2_000_000n, assets: {} })
            ],
            mockConstraints: NO_CONSTRAINTS,
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient
          });
        });
        it('Coin (Outputs+Fee>UTxO)', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: (utils) => [
              utils.createUnspentTxOutput({ coins: 4_910_000n, assets: {} }),
              utils.createUnspentTxOutput({ coins: 5_000_000n, assets: {} })
            ],
            createOutputs: (utils) => [utils.createOutput({ coins: 10_000_000n, assets: {} })],
            mockConstraints: {
              ...NO_CONSTRAINTS,
              minimumCost: 100_000n
            },
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient
          });
        });
        it('Asset', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: (utils) => [
              utils.createUnspentTxOutput({ coins: 10_000_000n, assets: { [TSLA_Asset]: 7000n } })
            ],
            createOutputs: (utils) => [utils.createOutput({ coins: 5_000_000n, assets: { [TSLA_Asset]: 7001n } })],
            mockConstraints: NO_CONSTRAINTS,
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient
          });
        });
        it('No UTxO', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: () => [],
            createOutputs: (utils) => [utils.createOutput({ coins: 5_000_000n })],
            mockConstraints: NO_CONSTRAINTS,
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient
          });
        });
      });
      describe('UTxO Fully Depleted', () => {
        it('Change bundle value is less than constrained', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: (utils) => [
              utils.createUnspentTxOutput({ coins: 1_000_000n }),
              utils.createUnspentTxOutput({ coins: 2_000_000n })
            ],
            createOutputs: (utils) => [utils.createOutput({ coins: 2_999_999n })],
            mockConstraints: {
              ...NO_CONSTRAINTS,
              minimumCoinQuantity: 2n
            },
            expectedError: InputSelectionFailure.UtxoFullyDepleted
          });
        });
        it('Change bundle size exceeds constraint', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: (utils) => [
              utils.createUnspentTxOutput({ coins: 2_000_000n, assets: { [TSLA_Asset]: 1000n, [PXL_Asset]: 1000n } })
            ],
            createOutputs: (utils) => [
              utils.createOutput({ coins: 1_000_000n, assets: { [TSLA_Asset]: 500n, [PXL_Asset]: 500n } })
            ],
            mockConstraints: {
              ...NO_CONSTRAINTS,
              maxTokenBundleSize: 1
            },
            expectedError: InputSelectionFailure.UtxoFullyDepleted
          });
        });
      });
      it('Maximum Input Count Exceeded', async () => {
        await testInputSelectionFailureMode({
          getAlgorithm: getRoundRobinRandomImprove,
          createUtxo: (utils) => [
            utils.createUnspentTxOutput({ coins: 2_000_000n }),
            utils.createUnspentTxOutput({ coins: 2_000_000n }),
            utils.createUnspentTxOutput({ coins: 3_000_000n })
          ],
          createOutputs: (utils) => [utils.createOutput({ coins: 6_000_000n })],
          mockConstraints: {
            ...NO_CONSTRAINTS,
            selectionLimit: 2
          },
          expectedError: InputSelectionFailure.MaximumInputCountExceeded
        });
      });
      // "UTxO Not Fragmented Enough" doesn't apply for this algorithm
    });
  });
  it('fast-check', async () => {
    const csl = await loadCardanoSerializationLib();
    const utils = createCslTestUtils(csl);
    const algorithm = getRoundRobinRandomImprove(csl);

    await fc.assert(
      fc.asyncProperty(generateSelectionParams(), async ({ utxoAmounts, outputsAmounts, constraints }) => {
        // Run input selection
        const utxo = utxoAmounts.map((valueQuantities) => utils.createUnspentTxOutput(valueQuantities));
        const outputs = outputsAmounts.map((valueQuantities) => utils.createOutput(valueQuantities));
        const outputsObj = utils.createOutputsObj(outputs);

        try {
          const results = await algorithm.select({
            utxo,
            outputs: outputsObj,
            constraints: toConstraints(constraints)
          });
          assertInputSelectionProperties({ utils, results, outputs, utxo, outputsObj, constraints });
        } catch (error) {
          if (error instanceof InputSelectionError) {
            assertFailureProperties({ error, utxoAmounts, outputsAmounts, constraints });
          } else {
            throw error;
          }
        }
      }),
      {
        interruptAfterTimeLimit: 100_000,
        markInterruptAsFailure: true,
        // endOnFailure: true,
        // seed: 895_642_751,
        // eslint-disable-next-line max-len
        // path: '8:3:1:2:1:2:2:1:5:1:1:6:2:4:4:1:7:1:4:1:4:1:3:1:1:3:1:1:1:1:13:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:7:16:12:12:14:14:11:11:13:11:12:11:14:12:11:12:11:14:13:11:11:14:11:11:11:12:13:11:12:11:15:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:14:15:14:14:16:0:4:1:11:1:1:10:1:1:1:1:2:2:2:2:3:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:2:3:4:3:3:5:1:1',
        // numRuns: 1
        numRuns: 500
      }
    );
  });
});
