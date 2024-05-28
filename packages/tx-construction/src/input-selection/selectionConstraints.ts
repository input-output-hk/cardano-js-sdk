import { Cardano, InvalidProtocolParametersError, Serialization } from '@cardano-sdk/core';
import {
  ComputeMinimumCoinQuantity,
  ComputeSelectionLimit,
  EstimateTxCosts,
  ProtocolParametersForInputSelection,
  ProtocolParametersRequiredByInputSelection,
  SelectionConstraints,
  SelectionSkeleton,
  TokenBundleSizeExceedsLimit,
  sortTxIn
} from '@cardano-sdk/input-selection';
import { MinFeeCoefficient, MinFeeConstant, minAdaRequired, minFee } from '../fees';
import { TxEvaluationResult, TxEvaluator, TxIdWithIndex } from '../tx-builder';

export const MAX_U64 = 18_446_744_073_709_551_615n;

export type BuildTx = (selection: SelectionSkeleton) => Promise<Cardano.Tx>;

export interface RedeemersByType {
  spend?: Map<TxIdWithIndex, Cardano.Redeemer>;
  mint?: Array<Cardano.Redeemer>;
  certificate?: Array<Cardano.Redeemer>;
  withdrawal?: Array<Cardano.Redeemer>;
  propose?: Array<Cardano.Redeemer>;
  vote?: Array<Cardano.Redeemer>;
}

export interface DefaultSelectionConstraintsProps {
  protocolParameters: ProtocolParametersForInputSelection;
  buildTx: BuildTx;
  redeemersByType: RedeemersByType;
  txEvaluator: TxEvaluator;
}

const updateRedeemers = (
  evaluation: TxEvaluationResult,
  redeemersByType: RedeemersByType,
  txInputs: Array<Cardano.TxIn>
): Array<Cardano.Redeemer> => {
  const result: Array<Cardano.Redeemer> = [];

  // Mapping between purpose and redeemersByType
  const redeemersMap: { [key in Cardano.RedeemerPurpose]?: Map<string, Cardano.Redeemer> | Cardano.Redeemer[] } = {
    [Cardano.RedeemerPurpose.spend]: redeemersByType.spend,
    [Cardano.RedeemerPurpose.mint]: redeemersByType.mint,
    [Cardano.RedeemerPurpose.certificate]: redeemersByType.certificate,
    [Cardano.RedeemerPurpose.withdrawal]: redeemersByType.withdrawal,
    [Cardano.RedeemerPurpose.propose]: redeemersByType.propose,
    [Cardano.RedeemerPurpose.vote]: redeemersByType.vote
  };

  for (const txEval of evaluation) {
    const redeemers = redeemersMap[txEval.purpose];
    if (!redeemers) throw new Error(`No redeemers found for ${txEval.purpose} purpose`);

    let knownRedeemer;
    if (txEval.purpose === Cardano.RedeemerPurpose.spend) {
      const input = txInputs[txEval.index];

      knownRedeemer = (redeemers as Map<string, Cardano.Redeemer>).get(`${input.txId}#${input.index}`);

      if (!knownRedeemer) throw new Error(`Known Redeemer not found for tx id ${input.txId} and index ${input.index}`);
    } else {
      const redeemerList = redeemers as Cardano.Redeemer[];

      knownRedeemer = redeemerList.find((redeemer) => redeemer.index === txEval.index);

      if (!knownRedeemer) throw new Error(`Known Redeemer not found for index ${txEval.index}`);
    }

    result.push({ ...knownRedeemer, executionUnits: txEval.budget });
  }

  return result;
};

const reorgRedeemers = (
  redeemerByType: RedeemersByType,
  witness: Cardano.Witness,
  txInputs: Array<Cardano.TxIn>
): Cardano.Redeemer[] => {
  let redeemers: Cardano.Redeemer[] = [];

  if (witness.redeemers) {
    // Lets remove all spend redeemers if any.
    redeemers = witness.redeemers.filter((redeemer) => redeemer.purpose !== Cardano.RedeemerPurpose.spend);

    // Add them back with the correct redeemer index.
    if (redeemerByType.spend) {
      for (const [key, value] of redeemerByType.spend) {
        const index = txInputs.findIndex((input) => key === `${input.txId}#${input.index}`);

        if (index < 0) throw new Error(`Redeemer not found for tx id ${key}`);

        value.index = index;

        redeemers.push({ ...value });
      }
    }
  }

  return redeemers;
};

export const computeMinimumCost =
  (
    {
      minFeeCoefficient,
      minFeeConstant,
      prices
    }: Pick<ProtocolParametersRequiredByInputSelection, 'minFeeCoefficient' | 'minFeeConstant' | 'prices'>,
    buildTx: BuildTx,
    txEvaluator: TxEvaluator,
    redeemersByType: RedeemersByType
  ): EstimateTxCosts =>
  async (selection) => {
    const tx = await buildTx(selection);
    const utxos = [...selection.inputs];
    const txIns = utxos.map((utxo) => utxo[0]).sort(sortTxIn);

    if (tx.witness && tx.witness.redeemers && tx.witness.redeemers.length > 0) {
      // before the evaluation can happen, we need to point every redeemer to its corresponding inputs.
      tx.witness.redeemers = reorgRedeemers(redeemersByType, tx.witness, txIns);
      tx.witness.redeemers = updateRedeemers(await txEvaluator.evaluate(tx, utxos), redeemersByType, txIns);
    }

    return {
      fee: minFee(tx, prices, MinFeeConstant(minFeeConstant), MinFeeCoefficient(minFeeCoefficient)),
      redeemers: tx.witness.redeemers
    };
  };

export const computeMinimumCoinQuantity =
  (coinsPerUtxoByte: ProtocolParametersRequiredByInputSelection['coinsPerUtxoByte']): ComputeMinimumCoinQuantity =>
  (output) =>
    minAdaRequired(output, BigInt(coinsPerUtxoByte));

export const tokenBundleSizeExceedsLimit =
  (maxValueSize: ProtocolParametersRequiredByInputSelection['maxValueSize']): TokenBundleSizeExceedsLimit =>
  (tokenBundle) => {
    if (!tokenBundle) {
      return false;
    }

    const value = new Serialization.Value(MAX_U64);
    value.setMultiasset(tokenBundle);

    return value.toCbor().length / 2 > maxValueSize;
  };

const getTxSize = (tx: Serialization.Transaction) => Buffer.from(tx.toCbor(), 'hex').length;

/**
 * This constraint implementation is not intended to used by selection algorithms
 * that adjust selection based on selection limit. RRRI implementation uses this after selecting all the inputs
 * and throws MaximumInputCountExceeded if the constraint returns a limit higher than number of selected utxo.
 *
 * @returns {ComputeSelectionLimit} constraint that returns txSize <= maxTxSize ? utxo[].length : utxo[].length-1
 */
export const computeSelectionLimit =
  (maxTxSize: ProtocolParametersRequiredByInputSelection['maxTxSize'], buildTx: BuildTx): ComputeSelectionLimit =>
  async (selectionSkeleton) => {
    const tx = await buildTx(selectionSkeleton);
    const txSize = getTxSize(Serialization.Transaction.fromCore(tx));
    if (txSize <= maxTxSize) {
      return selectionSkeleton.inputs.size;
    }
    return selectionSkeleton.inputs.size - 1;
  };

export const defaultSelectionConstraints = ({
  protocolParameters: { coinsPerUtxoByte, maxTxSize, maxValueSize, minFeeCoefficient, minFeeConstant, prices },
  buildTx,
  redeemersByType,
  txEvaluator
}: DefaultSelectionConstraintsProps): SelectionConstraints => {
  if (!coinsPerUtxoByte || !maxTxSize || !maxValueSize || !minFeeCoefficient || !minFeeConstant || !prices) {
    throw new InvalidProtocolParametersError(
      'Missing one of: coinsPerUtxoByte, maxTxSize, maxValueSize, minFeeCoefficient, minFeeConstant, prices'
    );
  }
  return {
    computeMinimumCoinQuantity: computeMinimumCoinQuantity(coinsPerUtxoByte),
    computeMinimumCost: computeMinimumCost(
      { minFeeCoefficient, minFeeConstant, prices },
      buildTx,
      txEvaluator,
      redeemersByType
    ),
    computeSelectionLimit: computeSelectionLimit(maxTxSize, buildTx),
    tokenBundleSizeExceedsLimit: tokenBundleSizeExceedsLimit(maxValueSize)
  };
};
