import { Epoch, Int64, NetworkMagic, UInt64 } from '@cardano-ogmios/schema';
import { Lovelace } from '.';
import { NetworkId } from '../NetworkId';

export type Ratio = number;

/**
 * A compact (without genesis UTxO) representation of the genesis configuration.
 */
export interface CompactGenesis {
  systemStart: Date;
  networkMagic: NetworkMagic;
  networkId: NetworkId;
  activeSlotsCoefficient: Ratio;
  securityParameter: UInt64;
  epochLength: Epoch;
  slotsPerKesPeriod: UInt64;
  maxKesEvolutions: UInt64;
  slotLength: Int64;
  updateQuorum: UInt64;
  maxLovelaceSupply: Lovelace;
}
