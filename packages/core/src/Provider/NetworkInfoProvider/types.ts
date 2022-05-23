import { Cardano, TimeSettings } from '../..';

export type AssetSupply = {
  circulating: Cardano.Lovelace;
  max: Cardano.Lovelace;
  total: Cardano.Lovelace;
};

export type StakeSummary = {
  active: Cardano.Lovelace;
  live: Cardano.Lovelace;
};

export type NetworkInfo = {
  network: {
    id: Cardano.NetworkId;
    magic: Cardano.NetworkMagic;
    timeSettings: TimeSettings[];
  };
  lovelaceSupply: AssetSupply;
  stake: StakeSummary;
};

export interface NetworkInfoProvider {
  networkInfo(): Promise<NetworkInfo>;
}
