/**
 * Represents the different types of governance actions within the Cardano blockchain ecosystem.
 */
export enum GovernanceActionKind {
  /**
   * Updates one or more updatable protocol parameters,
   * excluding changes to major protocol versions (i.e., "hard forks").
   */
  ParameterChange = 0,

  /**
   * Initiates a non-backwards compatible upgrade of the network.
   * This action necessitates a preceding software update.
   */
  HardForkInitiation = 1,

  /**
   * Withdraws funds from the treasury.
   */
  TreasuryWithdrawals = 2,

  /**
   * Propose a state of no-confidence in the current constitutional committee.
   * Allows Ada holders to challenge the authority granted to the existing committee.
   */
  NoConfidence = 3,

  /**
   * Modifies the composition of the constitutional committee,
   * its signature threshold, or its terms of operation.
   */
  UpdateCommittee = 4,

  /**
   * Changes or amendments the Constitution.
   */
  NewConstitution = 5,

  /**
   * Represents an action that has no direct effect on the blockchain,
   * but serves as an on-chain record or informative notice.
   */
  Info = 6
}
