import { Lovelace } from './Value';
import { NetworkId, NetworkMagic } from '../NetworkId';

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
  slotLength: number;
  updateQuorum: number;
  maxLovelaceSupply: Lovelace;
}
