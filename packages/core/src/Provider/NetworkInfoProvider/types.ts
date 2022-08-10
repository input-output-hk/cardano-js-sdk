import { Cardano, EraSummary, Provider } from '../..';

export type ProtocolParametersRequiredByWallet = Required<
  Pick<
    Cardano.ProtocolParametersBabbage,
    | 'coinsPerUtxoByte'
    | 'maxTxSize'
    | 'maxValueSize'
    | 'stakeKeyDeposit'
    | 'maxCollateralInputs'
    | 'minFeeCoefficient'
    | 'minFeeConstant'
    | 'minPoolCost'
    | 'poolDeposit'
    | 'protocolVersion'
  >
>;

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
