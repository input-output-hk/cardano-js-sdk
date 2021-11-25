import { Ed25519KeyHash, PoolId, VrfKeyHash } from './primitives';
import { Hash16 } from '../../util';
import { Lovelace } from '../Value';
import { Relay } from './Relay';
import { RewardAccount } from '../RewardAccount';

export interface Fraction {
  numerator: number;
  denominator: number;
}
export interface PoolMetadataJson {
  hash: Hash16; // TODO: verify this is the correct length (64 chars)
  url: string;
}

export interface PoolParameters {
  id: PoolId;
  rewardAccount: RewardAccount;
  /**
   * Declared pledge quantity.
   */
  pledge: Lovelace;
  /**
   * Fixed stake pool running cost
   */
  cost: Lovelace;
  /**
   * Stake pool margin percentage
   */
  margin: Fraction;
  /**
   * Metadata location and hash
   */
  metadataJson?: PoolMetadataJson;
  /**
   * Stake pool relays
   */
  relays: Relay[];

  owners: Ed25519KeyHash[];
  vrf: VrfKeyHash;
}
