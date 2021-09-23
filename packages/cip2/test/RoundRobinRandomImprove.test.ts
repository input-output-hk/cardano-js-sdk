import { roundRobinRandomImprove } from '../src/RoundRobinRandomImprove';
import { InputSelector, SelectionConstraints } from '../src/types';
import {
  TestUtils,
  createCslTestUtils,
  containsUtxo,
  TSLA_Asset,
  AllAssets,
  generateValidUtxoAndOutputs
} from './util';
import { InputSelectionError, InputSelectionFailure } from '../src/InputSelectionError';
import { loadCardanoSerializationLib, CardanoSerializationLib, CSL } from '@cardano-sdk/cardano-serialization-lib';
import fc from 'fast-check';

const getRoundRobinRandomImprove = (csl: CardanoSerializationLib) => roundRobinRandomImprove(csl);

const NO_CONSTRAINTS: SelectionConstraints = {
  computeMinimumCoinQuantity: () => 0n,
  tokenBundleSizeExceedsLimit: () => false,
  computeMinimumCost: async () => 0n,
  computeSelectionLimit: async () => Number.POSITIVE_INFINITY
};

interface InputSelectionFailureModeTestParams {
  /**
   * Test subject (Input Selection algorithm under test)
   */
  getAlgorithm: (SerializationLib: CardanoSerializationLib) => InputSelector;
  /**
   * Available UTxO
   */
  createUtxo: (utils: TestUtils) => CSL.TransactionUnspentOutput[];
  /**
   * Transaction outputs
   */
  createOutputs: (utils: TestUtils) => CSL.TransactionOutput[];
  /**
   * Input selection constraints passed to the algorithm.
   */
  constraints: SelectionConstraints;
  /**
   * Error that should be thrown
   */
  expectedError: InputSelectionFailure;
}

/**
 * Run input selection and assert that implementation throws error of specific failure.
 */
const testInputSelectionFailureMode = async ({
  getAlgorithm,
  createUtxo,
  createOutputs,
  expectedError,
  constraints
}: InputSelectionFailureModeTestParams) => {
  const SerializationLib = await loadCardanoSerializationLib();
  const utils = createCslTestUtils(SerializationLib);
  const utxo = createUtxo(utils);
  const outputs = createOutputs(utils);
  const algorithm = getAlgorithm(SerializationLib);
  await expect(algorithm.select({ utxo, outputs: utils.createOutputsObj(outputs), constraints })).rejects.toThrowError(
    new InputSelectionError(expectedError)
  );
};

describe('RoundRobinRandomImprove', () => {
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
          constraints: NO_CONSTRAINTS,
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
          constraints: {
            ...NO_CONSTRAINTS,
            computeMinimumCost: async () => 100_000n
          },
          expectedError: InputSelectionFailure.UtxoBalanceInsufficient
        });
      });
      it('Asset', async () => {
        await testInputSelectionFailureMode({
          getAlgorithm: getRoundRobinRandomImprove,
          createUtxo: (utils) => [utils.createUnspentTxOutput({ coins: 10_000_000n, assets: { [TSLA_Asset]: 7000n } })],
          createOutputs: (utils) => [utils.createOutput({ coins: 5_000_000n, assets: { [TSLA_Asset]: 7001n } })],
          constraints: NO_CONSTRAINTS,
          expectedError: InputSelectionFailure.UtxoBalanceInsufficient
        });
      });
      it('No UTxO', async () => {
        await testInputSelectionFailureMode({
          getAlgorithm: getRoundRobinRandomImprove,
          createUtxo: () => [],
          createOutputs: (utils) => [utils.createOutput({ coins: 5_000_000n })],
          constraints: NO_CONSTRAINTS,
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
          constraints: {
            ...NO_CONSTRAINTS,
            computeMinimumCoinQuantity: () => 2n
          },
          expectedError: InputSelectionFailure.UtxoFullyDepleted
        });
      });
      it('Change bundle size exceeds constraint', async () => {
        await testInputSelectionFailureMode({
          getAlgorithm: getRoundRobinRandomImprove,
          createUtxo: (utils) => [utils.createUnspentTxOutput({ coins: 2_000_000n })],
          createOutputs: (utils) => [utils.createOutput({ coins: 1_000_000n })],
          constraints: {
            ...NO_CONSTRAINTS,
            tokenBundleSizeExceedsLimit: () => true
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
        constraints: {
          ...NO_CONSTRAINTS,
          computeSelectionLimit: async () => 2
        },
        expectedError: InputSelectionFailure.MaximumInputCountExceeded
      });
    });
    // "UTxO Not Fragmented Enough" doesn't apply for this algorithm
  });
  it('Properties', async () => {
    const csl = await loadCardanoSerializationLib();
    const utils = createCslTestUtils(csl);
    const algorithm = getRoundRobinRandomImprove(csl);

    const constraints = {
      ...NO_CONSTRAINTS,
      computeMinimumCoinQuantity: () => 34_482n * 29n
    };

    await fc.assert(
      fc.asyncProperty(
        generateValidUtxoAndOutputs(constraints.computeMinimumCoinQuantity()),
        async ({ utxoAmounts, outputsAmounts }) => {
          // Run input selection
          const utxo = utxoAmounts.map((valueQuantities) => utils.createUnspentTxOutput(valueQuantities));
          const outputs = outputsAmounts.map((valueQuantities) => utils.createOutput(valueQuantities));
          const outputsObj = utils.createOutputsObj(outputs);
          const results = await algorithm.select({
            utxo,
            outputs: outputsObj,
            constraints
          });

          const vSelected = utils.getTotalInputAmounts(results);
          const vRequested = utils.getTotalOutputAmounts(outputs);

          // Coverage of Payments
          expect(vSelected.coins).toBeGreaterThanOrEqual(vRequested.coins);
          for (const assetName of AllAssets) {
            expect(vSelected.assets?.[assetName] || 0n).toBeGreaterThanOrEqual(vRequested.assets?.[assetName] || 0n);
          }

          // Correctness of Change
          const vChange = utils.getTotalChangeAmounts(results);
          expect(vSelected.coins).toEqual(vRequested.coins + vChange.coins);
          for (const assetName of AllAssets) {
            expect(vSelected.assets?.[assetName] || 0n).toEqual(
              (vRequested.assets?.[assetName] || 0n) + (vChange.assets?.[assetName] || 0n)
            );
          }

          // Conservation of UTxO
          for (const utxoEntry of utxo) {
            const isInInputSelectionInputsSet = containsUtxo(results.selection.inputs, utxoEntry);
            const isInRemainingUtxoSet = containsUtxo(results.remainingUTxO, utxoEntry);
            expect(isInInputSelectionInputsSet || isInRemainingUtxoSet).toBe(true);
            expect(isInInputSelectionInputsSet).not.toEqual(isInRemainingUtxoSet);
          }

          // Conservation of Outputs
          // If this is used to test other algorithms refactor this
          // to clone outputs before and do deepEquals to assert it wasn't mutated
          expect(results.selection.outputs).toEqual(outputsObj);

          // Min UTxO coin requirement for change
          const minUtxo = constraints.computeMinimumCoinQuantity();
          for (const value of results.selection.change) {
            expect(BigInt(value.coin().to_str())).toBeGreaterThanOrEqual(minUtxo);
          }
        }
      ),
      {
        interruptAfterTimeLimit: 100_000,
        markInterruptAsFailure: true,
        numRuns: 500
        // To rerun failed test:
        // seed: number
        // path: string
      }
    );
  });
});
