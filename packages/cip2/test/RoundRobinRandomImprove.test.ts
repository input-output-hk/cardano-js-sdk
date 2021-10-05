import { roundRobinRandomImprove } from '../src/RoundRobinRandomImprove';
import {
  assertInputSelectionProperties,
  assertFailureProperties,
  generateSelectionParams,
  testInputSelectionFailureMode,
  testInputSelectionProperties
} from './util';
import { InputSelectionError, InputSelectionFailure } from '../src/InputSelectionError';
import { loadCardanoSerializationLib, CardanoSerializationLib } from '@cardano-sdk/core';
import { AssetId, CslTestUtil, SelectionConstraints } from '@cardano-sdk/util-dev';
import fc from 'fast-check';

const getRoundRobinRandomImprove = (csl: CardanoSerializationLib) => roundRobinRandomImprove(csl);

describe('RoundRobinRandomImprove', () => {
  describe('Examples', () => {
    describe('Properties', () => {
      it('No change', async () => {
        await testInputSelectionProperties({
          getAlgorithm: getRoundRobinRandomImprove,
          createUtxo: (csl) => [CslTestUtil.createUnspentTxOutput(csl, { coins: 3_000_000n })],
          createOutputs: (csl) => [CslTestUtil.createOutput(csl, { coins: 3_000_000n })],
          mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
        });
      });
      it('No outputs', async () => {
        // Regression
        await testInputSelectionProperties({
          getAlgorithm: getRoundRobinRandomImprove,
          createUtxo: (csl) => [CslTestUtil.createUnspentTxOutput(csl, { coins: 11_999_994n })],
          createOutputs: () => [],
          mockConstraints: {
            ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
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
            createUtxo: (csl) => [
              CslTestUtil.createUnspentTxOutput(csl, { coins: 3_000_000n }),
              CslTestUtil.createUnspentTxOutput(csl, { coins: 10_000_000n })
            ],
            createOutputs: (csl) => [
              CslTestUtil.createOutput(csl, { coins: 12_000_000n }),
              CslTestUtil.createOutput(csl, { coins: 2_000_000n })
            ],
            mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS,
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient
          });
        });
        it('Coin (Outputs+Fee>UTxO)', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: (csl) => [
              CslTestUtil.createUnspentTxOutput(csl, { coins: 4_000_000n }),
              CslTestUtil.createUnspentTxOutput(csl, { coins: 5_000_000n })
            ],
            createOutputs: (csl) => [CslTestUtil.createOutput(csl, { coins: 9_000_000n })],
            mockConstraints: {
              ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
              minimumCost: 1n
            },
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient
          });
        });
        it('Asset', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: (csl) => [
              CslTestUtil.createUnspentTxOutput(csl, { coins: 10_000_000n, assets: { [AssetId.TSLA]: 7000n } })
            ],
            createOutputs: (csl) => [
              CslTestUtil.createOutput(csl, { coins: 5_000_000n, assets: { [AssetId.TSLA]: 7001n } })
            ],
            mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS,
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient
          });
        });
        it('No UTxO', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: () => [],
            createOutputs: (csl) => [CslTestUtil.createOutput(csl, { coins: 5_000_000n })],
            mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS,
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient
          });
        });
      });
      describe('UTxO Fully Depleted', () => {
        it('Change bundle value is less than constrained', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: (csl) => [
              CslTestUtil.createUnspentTxOutput(csl, { coins: 1_000_000n }),
              CslTestUtil.createUnspentTxOutput(csl, { coins: 2_000_000n })
            ],
            createOutputs: (csl) => [CslTestUtil.createOutput(csl, { coins: 2_999_999n })],
            mockConstraints: {
              ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
              minimumCoinQuantity: 2n
            },
            expectedError: InputSelectionFailure.UtxoFullyDepleted
          });
        });
        it('Change bundle size exceeds constraint', async () => {
          await testInputSelectionFailureMode({
            getAlgorithm: getRoundRobinRandomImprove,
            createUtxo: (csl) => [
              CslTestUtil.createUnspentTxOutput(csl, {
                coins: 2_000_000n,
                assets: { [AssetId.TSLA]: 1000n, [AssetId.PXL]: 1000n }
              })
            ],
            createOutputs: (csl) => [
              CslTestUtil.createOutput(csl, {
                coins: 1_000_000n,
                assets: { [AssetId.TSLA]: 500n, [AssetId.PXL]: 500n }
              })
            ],
            mockConstraints: {
              ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
              maxTokenBundleSize: 1
            },
            expectedError: InputSelectionFailure.UtxoFullyDepleted
          });
        });
      });
      it('Maximum Input Count Exceeded', async () => {
        await testInputSelectionFailureMode({
          getAlgorithm: getRoundRobinRandomImprove,
          createUtxo: (csl) => [
            CslTestUtil.createUnspentTxOutput(csl, { coins: 2_000_000n }),
            CslTestUtil.createUnspentTxOutput(csl, { coins: 2_000_000n }),
            CslTestUtil.createUnspentTxOutput(csl, { coins: 3_000_000n })
          ],
          createOutputs: (csl) => [CslTestUtil.createOutput(csl, { coins: 6_000_000n })],
          mockConstraints: {
            ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
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
    const algorithm = getRoundRobinRandomImprove(csl);

    await fc.assert(
      fc.asyncProperty(generateSelectionParams(), async ({ utxoAmounts, outputsAmounts, constraints }) => {
        // Run input selection
        const utxo = new Set(
          utxoAmounts.map((valueQuantities) => CslTestUtil.createUnspentTxOutput(csl, valueQuantities))
        );
        const outputs = new Set(
          outputsAmounts.map((valueQuantities) => CslTestUtil.createOutput(csl, valueQuantities))
        );

        try {
          const results = await algorithm.select({
            utxo: new Set(utxo),
            outputs,
            constraints: SelectionConstraints.mockConstraintsToConstraints(constraints)
          });
          assertInputSelectionProperties({ results, outputs, utxo, constraints });
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
