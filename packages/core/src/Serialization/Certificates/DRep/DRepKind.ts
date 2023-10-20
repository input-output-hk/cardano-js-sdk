/**
 * In order to participate in governance, a stake credential must be delegated to a DRep.
 * Ada holders will generally delegate their voting rights to a registered DRep that will
 * vote on their behalf.
 *
 * In addition, two pre-defined DRep options are available: `Abstain` and `No Confidence`.
 */
export enum DRepKind {
  /** A DRep identified by a stake key hash. */
  KeyHash = 0,

  /** A DRep identified by a script hash. */
  ScriptHash = 1,

  /**
   * If an Ada holder delegates to Abstain, then their stake is actively marked as not
   * participating in governance.
   *
   * The effect of delegating to Abstain on chain is that the delegated stake will not be
   * considered to be a part of the active voting stake. However, the stake will be considered
   * to be registered for the purpose of the incentives that are described in (Incentives
   * for Ada holders to delegate voting stake)[https://github.com/cardano-foundation/CIPs/blob/master/CIP-1694/README.md#incentives-for-ada-holders-to-delegate-voting-stake].
   */
  Abstain = 2,

  /**
   * If an Ada holder delegates to No Confidence, then their stake is counted as a Yes vote on
   * every No Confidence action and a No vote on every other action. The delegated stake will
   * be considered part of the active voting stake. It also serves as a directly auditable
   * measure of the confidence of Ada holders in the constitutional committee.
   */
  NoConfidence = 3
}
