/**
 * Enumeration to represent different kinds of voters within the Cardano governance system.
 */
export enum VoterKind {
  /**
   * Represents a constitutional committee member identified by a key hash.
   */
  ConstitutionalCommitteeKeyHash = 0,

  /**
   * Represents a constitutional committee member identified by a script hash.
   */
  ConstitutionalCommitteeScriptHash = 1,

  /**
   * Represents a DRep (Delegation Representative) identified by a key hash.
   */
  DrepKeyHash = 2,

  /**
   * Represents a DRep (Delegation Representative) identified by a script hash.
   */
  DRepScriptHash = 3,

  /**
   * Represents a Stake Pool Operator (SPO) identified by a key hash.
   */
  StakePoolKeyHash = 4
}
