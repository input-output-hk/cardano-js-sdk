import type { Cardano } from '@cardano-sdk/core';

export interface GenesisData {
  networkMagic: Cardano.NetworkMagic;
  networkId: 'Mainnet' | 'Testnet';
  maxLovelaceSupply: Cardano.Lovelace;
  activeSlotsCoefficient: number;
  securityParameter: number;
  systemStart: string;
  epochLength: number;
  slotsPerKesPeriod: number;
  maxKesEvolutions: number;
  slotLength: number;
  updateQuorum: number;
}

export type ModuleState = null | 'initializing' | 'initialized';
