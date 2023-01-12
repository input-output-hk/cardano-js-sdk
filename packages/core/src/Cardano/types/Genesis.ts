import { Lovelace } from './Value';
import { NetworkId, NetworkMagic } from '../ChainId';
import { Seconds } from '../../util';

/**
 * A compact (without genesis UTxO) representation of the genesis configuration.
 */
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
