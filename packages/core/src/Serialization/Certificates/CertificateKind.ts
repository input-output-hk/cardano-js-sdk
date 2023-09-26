/**
 * Certificates are used to register, update, or deregister stake pools, and delegate stake.
 *
 * These values are used for serialization.
 */
export enum CertificateKind {
  /**
   * This certificate is used when an individual wants to register as a stakeholder.
   * It allows the holder to participate in the staking process by delegating their
   * stake or creating a stake pool.
   */
  StakeRegistration = 0,

  /**
   * This certificate is used when a stakeholder no longer wants to participate in
   * staking. It revokes the stake registration and the associated stake is no
   * longer counted when calculating stake pool rewards.
   */
  StakeDeregistration = 1,

  /**
   * This certificate is used when a stakeholder wants to delegate their stake to a
   * specific stake pool. It includes the stake pool id to which the stake is delegated.
   */
  StakeDelegation = 2,

  /**
   * This certificate is used to register a new stake pool. It includes various details
   * about the pool such as the pledge, costs, margin, reward account, and the pool's owners and relays.
   */
  PoolRegistration = 3,

  /**
   * This certificate is used to retire a stake pool. It includes an epoch number
   * indicating when the pool will be retired.
   */
  PoolRetirement = 4,

  /**
   * This certificate is used to delegate from a Genesis key to a set of keys. This was primarily used in the early
   * phases of the Cardano network's existence during the transition from the Byron to the Shelley era.
   */
  GenesisKeyDelegation = 5,

  /**
   * Certificate used to facilitate an instantaneous transfer of rewards within the system.
   */
  MoveInstantaneousRewards = 6,

  /**
   * This certificate is used when an individual wants to register as a stakeholder.
   * It allows the holder to participate in the staking process by delegating their
   * stake or creating a stake pool.
   *
   * Deposit must match the expected deposit amount specified by `ppKeyDepositL` in
   * the protocol parameters.
   *
   * Remark: Replaces the deprecated `StakeRegistration` in after Conway era.
   */
  Registration = 7,

  /**
   * This certificate is used when a stakeholder no longer wants to participate in
   * staking. It revokes the stake registration and the associated stake is no
   * longer counted when calculating stake pool rewards.
   *
   * Deposit must match the expected deposit amount specified by `ppKeyDepositL` in
   * the protocol parameters.
   *
   * Remark: Replaces the deprecated `StakeDeregistration` in after Conway era.
   */
  Unregistration = 8,

  /**
   * This certificate is used when an individual wants to delegate their voting
   * rights to any other DRep.
   */
  VoteDelegation = 9,

  /**
   * This certificate is used when an individual wants to delegate their voting
   * rights to any other DRep and simultaneously wants to delegate their stake to a
   * specific stake pool.
   */
  StakeVoteDelegation = 10,

  /**
   * This certificate Register the stake key and delegate with a single certificate to a stake pool.
   */
  StakeRegistrationDelegation = 11,

  /**
   * This certificate Register the stake key and delegate with a single certificate to a DRep.
   */
  VoteRegistrationDelegation = 12,

  /**
   * This certificate is used when an individual wants to register its stake key,
   * delegate their voting rights to any other DRep and simultaneously wants to delegate
   * their stake to a specific stake pool.
   */
  StakeVoteRegistrationDelegation = 13,

  /**
   * This certificate registers the Hot and Cold credentials of a committee member.
   */
  AuthCommitteeHot = 14,

  /**
   * This certificate is used then a committee member wants to resign early
   * (will be marked on-chain as an expired member).
   */
  ResignCommitteeCold = 15,

  /**
   * In Voltaire, existing stake credentials will be able to delegate their stake to DReps for voting
   * purposes, in addition to the current delegation to stake pools for block production.
   * DRep delegation will mimic the existing stake delegation mechanisms (via on-chain certificates).
   *
   * This certificate register a stake key as a DRep.
   */
  DrepRegistration = 16,

  /**
   * This certificate unregister an individual as a DRep.
   *
   * Note that a DRep is retired immediately upon the chain accepting a retirement certificate, and
   * the deposit is returned as part of the transaction that submits the retirement certificate
   * (the same way that stake credential registration deposits are returned).
   */
  DrepUnregistration = 17,

  /**
   * Updates the DRep anchored metadata.
   */
  UpdateDrep = 18
}
