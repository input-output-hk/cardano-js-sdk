/**
 * The redeemer tags act as an enumeration to signify the purpose or context of the
 * redeemer in a transaction. When a Plutus script is executed, the specific action
 * type related to the redeemer can be identified using these tags, allowing the
 * script to respond appropriately.
 */
export enum RedeemerTag {
  /**
   * Indicates the redeemer is for spending a UTxO.
   */
  Spend = 0,
  /**
   * Indicates the redeemer is associated with a minting action.
   */
  Mint = 1,
  /**
   * Indicates the redeemer is related to a certificate action within a transaction.
   */
  Cert = 2,
  /**
   * Indicates the redeemer is for withdrawing rewards from staking.
   */
  Reward = 3
}
