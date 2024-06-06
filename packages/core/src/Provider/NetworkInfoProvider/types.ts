import type { Cardano, EraSummary, Provider } from '../../index.js';

export type SupplySummary = {
  circulating: Cardano.Lovelace;
  total: Cardano.Lovelace;
};

export type StakeSummary = {
  active: Cardano.Lovelace;
  live: Cardano.Lovelace;
};

export interface NetworkInfoProvider extends Provider {
  ledgerTip(): Promise<Cardano.Tip>;
  protocolParameters(): Promise<Cardano.ProtocolParameters>;
  genesisParameters(): Promise<Cardano.CompactGenesis>;
  lovelaceSupply(): Promise<SupplySummary>;
  stake(): Promise<StakeSummary>;
  eraSummaries(): Promise<EraSummary[]>;
}
