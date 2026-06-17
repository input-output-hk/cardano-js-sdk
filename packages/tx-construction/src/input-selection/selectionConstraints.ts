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
import { TxEvaluationResult, TxEvaluator, TxIdWithIndex } from '../tx-builder';
import { minAdaRequired, minFee } from '../fees';

export const MAX_U64 = 18_446_744_073_709_551_615n;

export type BuildTx = (selection: SelectionSkeleton) => Promise<Cardano.Tx>;

/**
 * Redeemers grouped by purpose. Each purpose is keyed by the on-chain identifier its redeemer
 * points at, so the canonical (ledger) redeemer index can be derived from the transaction body
 * during {@link computeMinimumCost}:
 *
 * - `spend` by `txId#index`
 * - `mint` by minting `PolicyId`
 * - `withdrawal` by script `RewardAccount`
 * - `vote` by `Voter`
 *
 * `certificate` and `propose` redeemers are sequence-indexed in transaction-body order, which is
 * what the ledger expects for those purposes, so they remain ordered lists.
 */
export interface RedeemersByType {
  spend?: Map<TxIdWithIndex, Cardano.Redeemer>;
  mint?: Map<Cardano.PolicyId, Cardano.Redeemer>;
  withdrawal?: Map<Cardano.RewardAccount, Cardano.Redeemer>;
  vote?: Array<{ voter: Cardano.Voter; redeemer: Cardano.Redeemer }>;
  certificate?: Array<Cardano.Redeemer>;
  propose?: Array<Cardano.Redeemer>;
}

export interface DefaultSelectionConstraintsProps {
  protocolParameters: ProtocolParametersForInputSelection;
  buildTx: BuildTx;
  redeemersByType: RedeemersByType;
  txEvaluator: TxEvaluator;
}

/** Lexicographic comparison of hex-encoded byte strings. */
const compareHex = (a: string, b: string): number => (a === b ? 0 : a < b ? -1 : 1);

const rewardAccountCredential = (rewardAccount: Cardano.RewardAccount): Cardano.Credential =>
  Cardano.Address.fromBech32(rewardAccount).asReward()!.getPaymentCredential();

/** Ledger ordering group for a voter constructor: ConstitutionalCommittee < DRep < StakePool. */
const voterGroup = (voter: Cardano.Voter): number => {
  switch (voter.__typename) {
    case Cardano.VoterType.ccHotKeyHash:
    case Cardano.VoterType.ccHotScriptHash:
      return 0;
    case Cardano.VoterType.dRepKeyHash:
    case Cardano.VoterType.dRepScriptHash:
      return 1;
    default:
      return 2;
  }
};

// Within a constructor the ledger Credential Ord places ScriptHash before KeyHash.
const credentialScriptFirstRank = (type: Cardano.CredentialType): number =>
  type === Cardano.CredentialType.ScriptHash ? 0 : 1;

const compareVoters = (a: Cardano.Voter, b: Cardano.Voter): number =>
  voterGroup(a) - voterGroup(b) ||
  credentialScriptFirstRank(a.credential.type) - credentialScriptFirstRank(b.credential.type) ||
  compareHex(a.credential.hash, b.credential.hash);

const votersEqual = (a: Cardano.Voter, b: Cardano.Voter): boolean =>
  a.__typename === b.__typename && a.credential.hash === b.credential.hash;

const reindexed = (
  redeemer: Cardano.Redeemer,
  purpose: Cardano.RedeemerPurpose,
  index: number,
  executionUnits: Cardano.ExUnits
): Cardano.Redeemer => ({ data: redeemer.data, executionUnits, index, purpose });

const spendRedeemers = (
  redeemersByType: RedeemersByType,
  sortedInputs: Array<Cardano.TxIn>,
  executionUnits: Cardano.ExUnits
): Cardano.Redeemer[] =>
  [...(redeemersByType.spend ?? [])].map(([key, redeemer]) => {
    const index = sortedInputs.findIndex((input) => key === `${input.txId}#${input.index}`);
    if (index < 0) throw new Error(`Spend redeemer input not found in transaction: ${key}`);
    return reindexed(redeemer, Cardano.RedeemerPurpose.spend, index, executionUnits);
  });

const mintRedeemers = (
  redeemersByType: RedeemersByType,
  body: Cardano.TxBody,
  executionUnits: Cardano.ExUnits
): Cardano.Redeemer[] => {
  const policyIds = [...new Set([...(body.mint?.keys() ?? [])].map(Cardano.AssetId.getPolicyId))].sort(compareHex);
  return [...(redeemersByType.mint ?? [])].map(([policyId, redeemer]) => {
    const index = policyIds.indexOf(policyId);
    if (index < 0) throw new Error(`Mint redeemer policy not present in transaction mint: ${policyId}`);
    return reindexed(redeemer, Cardano.RedeemerPurpose.mint, index, executionUnits);
  });
};

const withdrawalRedeemers = (
  redeemersByType: RedeemersByType,
  body: Cardano.TxBody,
  executionUnits: Cardano.ExUnits
): Cardano.Redeemer[] => {
  // Node quirk: withdrawal script credentials are processed before key-hash ones, so key-hash
  // withdrawals carry no redeemer and don't shift the index. Index = rank among script reward
  // accounts, sorted by credential hash.
  const scriptRewardAccounts = (body.withdrawals ?? [])
    .map((withdrawal) => withdrawal.stakeAddress)
    .filter((rewardAccount) => rewardAccountCredential(rewardAccount).type === Cardano.CredentialType.ScriptHash)
    .sort((a, b) => compareHex(rewardAccountCredential(a).hash, rewardAccountCredential(b).hash));
  return [...(redeemersByType.withdrawal ?? [])].map(([rewardAccount, redeemer]) => {
    const index = scriptRewardAccounts.indexOf(rewardAccount);
    if (index < 0) throw new Error(`Withdrawal redeemer is not a script withdrawal in transaction: ${rewardAccount}`);
    return reindexed(redeemer, Cardano.RedeemerPurpose.withdrawal, index, executionUnits);
  });
};

const voteRedeemers = (
  redeemersByType: RedeemersByType,
  body: Cardano.TxBody,
  executionUnits: Cardano.ExUnits
): Cardano.Redeemer[] => {
  const sortedVoters = (body.votingProcedures ?? []).map(({ voter }) => voter).sort(compareVoters);
  return (redeemersByType.vote ?? []).map(({ voter, redeemer }) => {
    const index = sortedVoters.findIndex((candidate) => votersEqual(candidate, voter));
    if (index < 0) throw new Error('Vote redeemer voter not present in transaction voting procedures');
    return reindexed(redeemer, Cardano.RedeemerPurpose.vote, index, executionUnits);
  });
};

/**
 * Assigns each redeemer its canonical ledger index, derived from the position of the item it
 * unlocks within the transaction body's canonically-ordered collections (mirroring the node's
 * `getAlonzoScriptsNeeded`). Certificate/proposal redeemers keep the caller-provided index, which
 * is the item's position in transaction-body order. `executionUnits` are seeded from the (already
 * max-budgeted) builder redeemers so evaluation has headroom; concrete units are merged back in
 * via {@link mergeExecutionUnits}.
 */
const assignCanonicalIndices = (
  redeemersByType: RedeemersByType,
  body: Cardano.TxBody,
  sortedInputs: Array<Cardano.TxIn>,
  executionUnits: Cardano.ExUnits
): Cardano.Redeemer[] => [
  ...spendRedeemers(redeemersByType, sortedInputs, executionUnits),
  ...mintRedeemers(redeemersByType, body, executionUnits),
  ...withdrawalRedeemers(redeemersByType, body, executionUnits),
  ...voteRedeemers(redeemersByType, body, executionUnits),
  ...(redeemersByType.certificate ?? []).map((redeemer) =>
    reindexed(redeemer, Cardano.RedeemerPurpose.certificate, redeemer.index, executionUnits)
  ),
  ...(redeemersByType.propose ?? []).map((redeemer) =>
    reindexed(redeemer, Cardano.RedeemerPurpose.propose, redeemer.index, executionUnits)
  )
];

/** Merges evaluated execution units back onto the canonically-indexed redeemers by (purpose, index). */
const mergeExecutionUnits = (redeemers: Cardano.Redeemer[], evaluation: TxEvaluationResult): Cardano.Redeemer[] =>
  redeemers.map((redeemer) => {
    const evaluated = evaluation.find(
      (txEval) => txEval.purpose === redeemer.purpose && txEval.index === redeemer.index
    );
    return evaluated ? { ...redeemer, executionUnits: evaluated.budget } : redeemer;
  });

export const computeMinimumCost =
  (
    pparams: ProtocolParametersForInputSelection,
    buildTx: BuildTx,
    txEvaluator: TxEvaluator,
    redeemersByType: RedeemersByType
  ): EstimateTxCosts =>
  async (selection) => {
    const tx = await buildTx(selection);
    const utxos = [...selection.inputs];
    const txIns = utxos.map((utxo) => utxo[0]).sort(sortTxIn);

    if (tx.witness && tx.witness.redeemers && tx.witness.redeemers.length > 0) {
      // The builder redeemers carry a sentinel index and a max-budget; reassign canonical indices
      // from the transaction body, evaluate, then merge the concrete execution units back in.
      const maxBudget = tx.witness.redeemers[0].executionUnits;
      const indexed = assignCanonicalIndices(redeemersByType, tx.body, txIns, maxBudget);
      tx.witness.redeemers = indexed;
      tx.witness.redeemers = mergeExecutionUnits(indexed, await txEvaluator.evaluate(tx, utxos));
    }

    return {
      fee: minFee(tx, utxos, pparams),
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
  protocolParameters,
  buildTx,
  redeemersByType,
  txEvaluator
}: DefaultSelectionConstraintsProps): SelectionConstraints => {
  if (
    !protocolParameters.coinsPerUtxoByte ||
    !protocolParameters.maxTxSize ||
    !protocolParameters.maxValueSize ||
    !protocolParameters.minFeeCoefficient ||
    !protocolParameters.minFeeConstant ||
    !protocolParameters.prices
  ) {
    throw new InvalidProtocolParametersError(
      'Missing one of: coinsPerUtxoByte, maxTxSize, maxValueSize, minFeeCoefficient, minFeeConstant, prices'
    );
  }
  return {
    computeMinimumCoinQuantity: computeMinimumCoinQuantity(protocolParameters.coinsPerUtxoByte),
    computeMinimumCost: computeMinimumCost(protocolParameters, buildTx, txEvaluator, redeemersByType),
    computeSelectionLimit: computeSelectionLimit(protocolParameters.maxTxSize, buildTx),
    tokenBundleSizeExceedsLimit: tokenBundleSizeExceedsLimit(protocolParameters.maxValueSize)
  };
};
