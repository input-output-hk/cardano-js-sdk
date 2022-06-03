import { Cardano } from '@cardano-sdk/core';

export interface CirculatingSupplyModel {
  circulating_supply: string;
}

export interface TotalSupplyModel {
  total_supply: string;
}

export interface ActiveStakeModel {
  active_stake: string;
}

export interface LiveStakeModel {
  live_stake: string;
}

export interface GenesisData {
  networkMagic: Cardano.CardanoNetworkMagic;
  networkId: Cardano.CardanoNetworkId;
  maxLovelaceSupply: Cardano.Lovelace;
}
