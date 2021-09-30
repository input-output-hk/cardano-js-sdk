import { roundRobinRandomImprove } from '../src/RoundRobinRandomImprove';
import {
  assertInputSelectionProperties,
  assertFailureProperties,
  createCslTestUtils,
  generateSelectionParams,
  NO_CONSTRAINTS,
  toConstraints,
  PXL_Asset,
  TSLA_Asset,
  testInputSelectionFailureMode,
  testInputSelectionProperties
} from './util';
import { InputSelectionError, InputSelectionFailure } from '../src/InputSelectionError';
import { loadCardanoSerializationLib, CardanoSerializationLib } from '@cardano-sdk/core';
import fc from 'fast-check';

const getRoundRobinRandomImprove = (csl: CardanoSerializationLib) => roundRobinRandomImprove(csl);

describe('RoundRobinRandomImprove', () => {
  describe('Examples', () => {
    describe('Properties', () => {
      it('No change', async () => {
        await testInputSelectionProperties({
          getAlgorithm: getRoundRobinRandomImprove,
          createUtxo: (utils) => [utils.createUnspentTxOutput({ coins: 3_000_000n })],
          createOutputs: (utils) => [utils.createOutput({ coins: 3_000_000n })],
          mockConstraints: NO_CONSTRAINTS
        });
      });
      it('No outputs', async () => {
        // Regression
        await testInputSelectionProperties({
          getAlgorithm: getRoundRobinRandomImprove,
          createUtxo: (utils) => [utils.createUnspentTxOutput({ coins: 11_999_994n })],
          createOutputs: () => [],
          mockConstraints: {
            ...NO_CONSTRAINTS,
            minimumCoinQuantity: 9_999_991n,
            minimumCost: 2_000_003n
          }
        });
      });
    });
    describe('Failure Modes', () => {
      describe('UtxoBalanceInsufficient', () => {
        it('Coin (Outputs>UTxO)', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: (utils) => [
              utils.createUnspentTxOutput({ coins: 3_000_000n }),
              utils.createUnspentTxOutput({ coins: 10_000_000n })
            ],
            createOutputs: (utils) => [
              utils.createOutput({ coins: 12_000_000n }),
              utils.createOutput({ coins: 2_000_000n })
            ],
            mockConstraints: NO_CONSTRAINTS,
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient
          });
        });
        it('Coin (Outputs+Fee>UTxO)', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: (utils) => [
              utils.createUnspentTxOutput({ coins: 4_000_000n }),
              utils.createUnspentTxOutput({ coins: 5_000_000n })
            ],
            createOutputs: (utils) => [utils.createOutput({ coins: 9_000_000n })],
            mockConstraints: {
              ...NO_CONSTRAINTS,
              minimumCost: 1n
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

        try {
          const results = await algorithm.select({
            utxo,
            outputs,
            constraints: toConstraints(constraints)
          });
          assertInputSelectionProperties({ utils, results, outputs, utxo, constraints });
        } catch (error) {
          if (error instanceof InputSelectionError) {
            assertFailureProperties({ error, utxoAmounts, outputsAmounts, constraints });
          } else {
            throw error;
          }
        }
      })
    );
  });
});
