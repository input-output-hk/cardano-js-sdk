import type { Lovelace } from './Value.js';
import type { NetworkId, NetworkMagic } from '../ChainId.js';
import type { Seconds } from '../../util/index.js';

/** A compact (without genesis UTxO) representation of the genesis configuration. */
export interface CompactGenesis {
  systemStart: Date;
  networkMagic: NetworkMagic;
  networkId: NetworkId;
  activeSlotsCoefficient: number;
  securityParameter: number;
  epochLength: number;
  slotsPerKesPeriod: number;
  maxKesEvolutions: number;
  slotLength: Seconds;
  updateQuorum: number;
  maxLovelaceSupply: Lovelace;
}
