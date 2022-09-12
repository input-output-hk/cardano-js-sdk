import { Cardano, EraSummary, Provider } from '../..';

export type ProtocolParametersRequiredByWallet = Omit<Cardano.ProtocolParameters, 'costModels'>;

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
  currentWalletProtocolParameters(): Promise<ProtocolParametersRequiredByWallet>;
  genesisParameters(): Promise<Cardano.CompactGenesis>;
  lovelaceSupply(): Promise<SupplySummary>;
  stake(): Promise<StakeSummary>;
  eraSummaries(): Promise<EraSummary[]>;
}
