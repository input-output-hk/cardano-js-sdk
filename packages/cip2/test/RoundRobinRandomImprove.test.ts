import { AssetId, CslTestUtil, SelectionConstraints } from '@cardano-sdk/util-dev';
import { InputSelectionError, InputSelectionFailure } from '../src/InputSelectionError';
import {
  assertFailureProperties,
  assertInputSelectionProperties,
  generateSelectionParams,
  testInputSelectionFailureMode,
  testInputSelectionProperties
} from './util';
import { createOutput } from '@cardano-sdk/util-dev/src/cslTestUtil';
import { roundRobinRandomImprove } from '../src/RoundRobinRandomImprove';
import fc from 'fast-check';

describe('RoundRobinRandomImprove', () => {
  describe('Examples', () => {
    describe('Properties', () => {
      it('No change', async () => {
        await testInputSelectionProperties({
          createOutputs: () => [CslTestUtil.createOutput({ coins: 3_000_000n })],
          createUtxo: () => [CslTestUtil.createUnspentTxOutput({ coins: 3_000_000n })],
          getAlgorithm: roundRobinRandomImprove,
          mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
        });
      });
      it('No outputs', async () => {
        // Regression
        await testInputSelectionProperties({
          createOutputs: () => [],
          createUtxo: () => [CslTestUtil.createUnspentTxOutput({ coins: 11_999_994n })],
          getAlgorithm: roundRobinRandomImprove,
          mockConstraints: {
            ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
            minimumCoinQuantity: 9_999_991n,
            minimumCost: 2_000_003n
          }
        });
      });
      it('Selects UTxO even when implicit input covers outputs', async () => {
        const utxo = new Set([CslTestUtil.createUnspentTxOutput({ coins: 10_000_000n })]);
        const outputs = new Set([createOutput({ coins: 1_000_000n })]);
        const results = await roundRobinRandomImprove().select({
          constraints: SelectionConstraints.NO_CONSTRAINTS,
          implicitCoin: { input: 2_000_000n },
          outputs,
          utxo
        });
        expect(results.selection.inputs.size).toBe(1);
      });
    });
    describe('Failure Modes', () => {
      describe('UtxoBalanceInsufficient', () => {
        it('Coin (Outputs>UTxO)', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [
              CslTestUtil.createOutput({ coins: 12_000_000n }),
              CslTestUtil.createOutput({ coins: 2_000_000n })
            ],
            createUtxo: () => [
              CslTestUtil.createUnspentTxOutput({ coins: 3_000_000n }),
              CslTestUtil.createUnspentTxOutput({ coins: 10_000_000n })
            ],
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient,
            getAlgorithm: roundRobinRandomImprove,
            mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
          });
        });
        it('Coin (Outputs+Fee>UTxO)', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [CslTestUtil.createOutput({ coins: 9_000_000n })],
            createUtxo: () => [
              CslTestUtil.createUnspentTxOutput({ coins: 4_000_000n }),
              CslTestUtil.createUnspentTxOutput({ coins: 5_000_000n })
            ],
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient,
            getAlgorithm: roundRobinRandomImprove,
            mockConstraints: {
              ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
              minimumCost: 1n
            }
          });
        });
        it('Asset', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [CslTestUtil.createOutput({ assets: { [AssetId.TSLA]: 7001n }, coins: 5_000_000n })],
            createUtxo: () => [
              CslTestUtil.createUnspentTxOutput({ assets: { [AssetId.TSLA]: 7000n }, coins: 10_000_000n })
            ],
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient,
            getAlgorithm: roundRobinRandomImprove,
            mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
          });
        });
        it('No UTxO', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [CslTestUtil.createOutput({ coins: 5_000_000n })],
            createUtxo: () => [],
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient,
            getAlgorithm: roundRobinRandomImprove,
            mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
          });
        });
      });
      describe('UTxO Fully Depleted', () => {
        it('Change bundle value is less than constrained', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [CslTestUtil.createOutput({ coins: 2_999_999n })],
            createUtxo: () => [
              CslTestUtil.createUnspentTxOutput({ coins: 1_000_000n }),
              CslTestUtil.createUnspentTxOutput({ coins: 2_000_000n })
            ],
            expectedError: InputSelectionFailure.UtxoFullyDepleted,
            getAlgorithm: roundRobinRandomImprove,
            mockConstraints: {
              ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
              minimumCoinQuantity: 2n
            }
          });
        });
        it('Change bundle size exceeds constraint', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [
              CslTestUtil.createOutput({
                assets: { [AssetId.TSLA]: 500n, [AssetId.PXL]: 500n },
                coins: 1_000_000n
              })
            ],
            createUtxo: () => [
              CslTestUtil.createUnspentTxOutput({
                assets: { [AssetId.TSLA]: 1000n, [AssetId.PXL]: 1000n },
                coins: 2_000_000n
              })
            ],
            expectedError: InputSelectionFailure.UtxoFullyDepleted,
            getAlgorithm: roundRobinRandomImprove,
            mockConstraints: {
              ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
              maxTokenBundleSize: 1
            }
          });
        });
      });
      it('Maximum Input Count Exceeded', async () => {
        await testInputSelectionFailureMode({
          createOutputs: () => [CslTestUtil.createOutput({ coins: 6_000_000n })],
          createUtxo: () => [
            CslTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
            CslTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
            CslTestUtil.createUnspentTxOutput({ coins: 3_000_000n })
          ],
          expectedError: InputSelectionFailure.MaximumInputCountExceeded,
          getAlgorithm: roundRobinRandomImprove,
          mockConstraints: {
            ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
            selectionLimit: 2
          }
        });
      });
      // "UTxO Not Fragmented Enough" doesn't apply for this algorithm
    });
  });
  it('fast-check', async () => {
    const algorithm = roundRobinRandomImprove();

    await fc.assert(
      fc.asyncProperty(
        generateSelectionParams(),
        async ({ utxoAmounts, outputsAmounts, constraints, implicitCoin }) => {
          // Run input selection
          const utxo = new Set(
            utxoAmounts.map((valueQuantities) => CslTestUtil.createUnspentTxOutput(valueQuantities))
          );
          const outputs = new Set(outputsAmounts.map((valueQuantities) => CslTestUtil.createOutput(valueQuantities)));

          try {
            const results = await algorithm.select({
              constraints: SelectionConstraints.mockConstraintsToConstraints(constraints),
              implicitCoin,
              outputs,
              utxo: new Set(utxo)
            });
            assertInputSelectionProperties({ constraints, implicitCoin, outputs, results, utxo });
          } catch (error) {
            if (error instanceof InputSelectionError) {
              assertFailureProperties({ constraints, error, implicitCoin, outputsAmounts, utxoAmounts });
            } else {
              throw error;
            }
          }
        }
      )
    );
  });
});
