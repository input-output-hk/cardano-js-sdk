import { AssetId, TxTestUtil } from '@cardano-sdk/util-dev';
import { GreedyInputSelector, InputSelectionError } from '../src/index.js';
import { InputSelectionFailure } from '../src/InputSelectionError.js';
import {
  SelectionConstraints,
  asPaymentAddress,
  assertFailureProperties,
  assertInputSelectionProperties,
  generateSelectionParams,
  testInputSelectionFailureMode,
  testInputSelectionProperties
} from './util/index.js';
import { coalesceValueQuantities } from '@cardano-sdk/core';
import { roundRobinRandomImprove } from '../src/RoundRobinRandomImprove/index.js';
import fc from 'fast-check';
import type { Cardano } from '@cardano-sdk/core';
import type { ChangeAddressResolver, InputSelector, Selection } from '../src/index.js';

const changeAddress =
  'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9' as Cardano.PaymentAddress;

class MockChangeAddressResolver implements ChangeAddressResolver {
  async resolve(selection: Selection) {
    return selection.change.map((txOut) => {
      txOut.address = changeAddress;
      return txOut;
    });
  }
}

const createRoundRobinRandomImprove = () =>
  roundRobinRandomImprove({
    changeAddressResolver: new MockChangeAddressResolver()
  });

const createGreedySelector = () =>
  new GreedyInputSelector({
    getChangeAddresses: async () => new Map([[asPaymentAddress('A'), 1]])
  });

const testInputSelection = (name: string, getAlgorithm: () => InputSelector) => {
  describe(name, () => {
    describe('Properties', () => {
      it('No change', async () => {
        await testInputSelectionProperties({
          createOutputs: () => [TxTestUtil.createOutput({ coins: 3_000_000n })],
          createPreSelectedOutputUtxo: () => [],
          createUtxo: () => [TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n })],
          getAlgorithm,
          mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
        });
      });
      it('No outputs', async () => {
        // Regression
        await testInputSelectionProperties({
          createOutputs: () => [],
          createPreSelectedOutputUtxo: () => [],
          createUtxo: () => [TxTestUtil.createUnspentTxOutput({ coins: 30_999_994n })],
          getAlgorithm,
          mockConstraints: {
            ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
            minimumCoinQuantity: 9_999_991n,
            minimumCostCoefficient: 2_000_003n
          }
        });
      });
      it('0 token change', async () => {
        // Regression
        await testInputSelectionProperties({
          createOutputs: () => [TxTestUtil.createOutput({ assets: new Map([[AssetId.TSLA, 7001n]]), coins: 1000n })],
          createPreSelectedOutputUtxo: () => [],
          createUtxo: () => [
            TxTestUtil.createUnspentTxOutput({ assets: new Map([[AssetId.TSLA, 7001n]]), coins: 11_999_994n })
          ],
          getAlgorithm,
          mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
        });
      });

      it('can use pre selected inputs', async () => {
        await testInputSelectionProperties({
          createOutputs: () => [TxTestUtil.createOutput({ assets: new Map([[AssetId.B, 999n]]), coins: 9_000_000n })],
          createPreSelectedOutputUtxo: () => [
            TxTestUtil.createUnspentTxOutput({ assets: new Map([[AssetId.TSLA, 1n]]), coins: 1000n })
          ],
          createUtxo: () => [
            TxTestUtil.createUnspentTxOutput({ assets: new Map([[AssetId.B, 999n]]), coins: 99_000_000n })
          ],
          getAlgorithm,
          mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
        });
      });

      it('selects pre selected inputs', async () => {
        const preSelectedUtxo = new Set<Cardano.Utxo>([
          TxTestUtil.createUnspentTxOutput({ assets: new Map([[AssetId.TSLA, 1n]]), coins: 1000n })
        ]);
        const utxo = new Set([TxTestUtil.createUnspentTxOutput({ coins: 10_000_000n })]);
        const outputs = new Set([TxTestUtil.createOutput({ coins: 5_000_000n })]);
        const results = await getAlgorithm().select({
          constraints: SelectionConstraints.NO_CONSTRAINTS,
          implicitValue: { coin: { input: 2_000_000n } },
          outputs,
          preSelectedUtxo,
          utxo
        });
        expect(results.selection.inputs.size).toBe(2);
        expect([...results.selection.inputs].some((output) => output[1].value.assets?.has(AssetId.TSLA))).toBeTruthy();
      });

      it('Selects UTxO even when implicit input covers outputs', async () => {
        const preSelectedUtxo = new Set<Cardano.Utxo>();
        const utxo = new Set([TxTestUtil.createUnspentTxOutput({ coins: 10_000_000n })]);
        const outputs = new Set([TxTestUtil.createOutput({ coins: 1_000_000n })]);
        const results = await getAlgorithm().select({
          constraints: SelectionConstraints.NO_CONSTRAINTS,
          implicitValue: { coin: { input: 2_000_000n } },
          outputs,
          preSelectedUtxo,
          utxo
        });
        expect(results.selection.inputs.size).toBe(1);
      });
    });

    describe('mint', () => {
      const assetId = AssetId.TSLA;

      it('Considers positive quantity mint as implicit input', async () => {
        const preSelectedUtxo = new Set<Cardano.Utxo>();
        const utxo = new Set([TxTestUtil.createUnspentTxOutput({ coins: 10_000_000n })]);
        const assets = new Map([[assetId, 100n]]);
        const outputs = new Set([TxTestUtil.createOutput({ assets, coins: 1_000_000n })]);
        const results = await getAlgorithm().select({
          constraints: SelectionConstraints.NO_CONSTRAINTS,
          implicitValue: { mint: new Map(assets.entries()) },
          outputs,
          preSelectedUtxo,
          utxo
        });
        expect(results.selection.inputs.size).toBe(1);
        expect(results.selection.outputs).toBe(outputs);
      });

      it('Considers negative quantity mint as implicit spend', async () => {
        const burnQuantity = 100n;
        const expectedChangeQuantity = 30n;
        const utxo = new Set([
          TxTestUtil.createUnspentTxOutput({
            assets: new Map([[assetId, burnQuantity + expectedChangeQuantity]]),
            coins: 10_000_000n
          })
        ]);
        const preSelectedUtxo = new Set<Cardano.Utxo>();
        const outputs = new Set([TxTestUtil.createOutput({ coins: 1_000_000n })]);
        const results = await getAlgorithm().select({
          constraints: SelectionConstraints.NO_CONSTRAINTS,
          implicitValue: { mint: new Map([[assetId, -burnQuantity]]) },
          outputs,
          preSelectedUtxo,
          utxo
        });
        expect(results.selection.inputs.size).toBe(1);
        expect(results.selection.outputs).toBe(outputs);
        const totalChange = coalesceValueQuantities(results.selection.change.map((txOut) => txOut.value));
        expect(totalChange.assets!.get(assetId)).toBe(expectedChangeQuantity);
      });
    });
    describe('Failure Modes', () => {
      describe('UtxoBalanceInsufficient', () => {
        it('Coin (Outputs>UTxO)', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [
              TxTestUtil.createOutput({ coins: 12_000_000n }),
              TxTestUtil.createOutput({ coins: 2_000_000n })
            ],
            createPreSelectedOutputUtxo: () => [],
            createUtxo: () => [
              TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n }),
              TxTestUtil.createUnspentTxOutput({ coins: 10_000_000n })
            ],
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient,
            getAlgorithm,
            mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
          });
        });
        it('Coin (Outputs+Fee>UTxO)', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [TxTestUtil.createOutput({ coins: 9_000_000n })],
            createPreSelectedOutputUtxo: () => [],
            createUtxo: () => [
              TxTestUtil.createUnspentTxOutput({ coins: 4_000_000n }),
              TxTestUtil.createUnspentTxOutput({ coins: 5_000_000n })
            ],
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient,
            getAlgorithm,
            mockConstraints: {
              ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
              minimumCostCoefficient: 1n
            }
          });
        });
        it('Asset', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [
              TxTestUtil.createOutput({ assets: new Map([[AssetId.TSLA, 7001n]]), coins: 5_000_000n })
            ],
            createPreSelectedOutputUtxo: () => [],
            createUtxo: () => [
              TxTestUtil.createUnspentTxOutput({ assets: new Map([[AssetId.TSLA, 7000n]]), coins: 10_000_000n })
            ],
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient,
            getAlgorithm,
            mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
          });
        });
        it('No UTxO', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [TxTestUtil.createOutput({ coins: 5_000_000n })],
            createPreSelectedOutputUtxo: () => [],
            createUtxo: () => [],
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient,
            getAlgorithm,
            mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
          });
        });
        it('Attempting to burn tokens with insufficient quantity in utxo', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [],
            createPreSelectedOutputUtxo: () => [],
            createUtxo: () => [TxTestUtil.createUnspentTxOutput({ coins: 10_000_000n })],
            expectedError: InputSelectionFailure.UtxoBalanceInsufficient,
            getAlgorithm,
            implicitValue: { mint: new Map([[AssetId.TSLA, -4n]]) },
            mockConstraints: SelectionConstraints.MOCK_NO_CONSTRAINTS
          });
        });
        it('Maximum Input Count Exceeded', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [TxTestUtil.createOutput({ coins: 6_000_000n })],
            createPreSelectedOutputUtxo: () => [],
            createUtxo: () => [
              TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
              TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n }),
              TxTestUtil.createUnspentTxOutput({ coins: 3_000_000n })
            ],
            expectedError: InputSelectionFailure.MaximumInputCountExceeded,
            getAlgorithm,
            mockConstraints: {
              ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
              selectionLimit: 2
            }
          });
        });
      });
      describe('UTxO Fully Depleted', () => {
        it('Change bundle value is less than constrained', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [TxTestUtil.createOutput({ coins: 2_999_999n })],
            createPreSelectedOutputUtxo: () => [],
            createUtxo: () => [
              TxTestUtil.createUnspentTxOutput({ coins: 1_000_000n }),
              TxTestUtil.createUnspentTxOutput({ coins: 2_000_000n })
            ],
            expectedError: InputSelectionFailure.UtxoFullyDepleted,
            getAlgorithm,
            mockConstraints: {
              ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
              minimumCoinQuantity: 2n
            }
          });
        });
        it('Change bundle size exceeds constraint', async () => {
          await testInputSelectionFailureMode({
            createOutputs: () => [
              TxTestUtil.createOutput({
                assets: new Map([
                  [AssetId.TSLA, 500n],
                  [AssetId.PXL, 500n]
                ]),
                coins: 1_000_000n
              })
            ],
            createPreSelectedOutputUtxo: () => [],
            createUtxo: () => [
              TxTestUtil.createUnspentTxOutput({
                assets: new Map([
                  [AssetId.TSLA, 1000n],
                  [AssetId.PXL, 1000n],
                  [AssetId.Unit, 1000n],
                  [AssetId.A, 1000n],
                  [AssetId.B, 1000n],
                  [AssetId.C, 1000n],
                  [AssetId.D, 1000n]
                ]),
                coins: 2_000_000n
              })
            ],
            expectedError: InputSelectionFailure.UtxoFullyDepleted,
            getAlgorithm,
            mockConstraints: {
              ...SelectionConstraints.MOCK_NO_CONSTRAINTS,
              maxTokenBundleSize: 1
            }
          });
        });
      });
    });
    it('fast-check', async () => {
      const algorithm = getAlgorithm();

      await fc.assert(
        fc.asyncProperty(
          generateSelectionParams(),
          async ({ utxoAmounts, outputsAmounts, constraints, implicitValue }) => {
            // Run input selection
            const utxo = new Set(
              utxoAmounts.map((valueQuantities) => TxTestUtil.createUnspentTxOutput(valueQuantities))
            );
            const outputs = new Set(outputsAmounts.map((valueQuantities) => TxTestUtil.createOutput(valueQuantities)));
            const preSelectedUtxo = new Set<Cardano.Utxo>();
            try {
              const results = await algorithm.select({
                constraints: SelectionConstraints.mockConstraintsToConstraints(constraints),
                implicitValue,
                outputs,
                preSelectedUtxo,
                utxo: new Set(utxo)
              });
              assertInputSelectionProperties({ constraints, implicitValue, outputs, results, utxo });
            } catch (error) {
              if (error instanceof InputSelectionError) {
                assertFailureProperties({ constraints, error, implicitValue, outputsAmounts, utxoAmounts });
              } else {
                throw error;
              }
            }
          }
        )
      );
    });
  });
};

testInputSelection('RoundRobinRandomImprove', createRoundRobinRandomImprove);
testInputSelection('GreedySelector', createGreedySelector);
