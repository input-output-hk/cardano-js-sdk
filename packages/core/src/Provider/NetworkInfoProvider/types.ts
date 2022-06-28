import { Cardano, TimeSettings } from '../..';

export type ProtocolParametersRequiredByWallet = Required<
  Pick<
    Cardano.ProtocolParametersAlonzo,
    | 'coinsPerUtxoWord'
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

export interface NetworkInfoProvider<Tip = Cardano.Tip> {
  ledgerTip(): Promise<Tip>;
  currentWalletProtocolParameters(): Promise<ProtocolParametersRequiredByWallet>;
  genesisParameters(): Promise<Cardano.CompactGenesis>;
  lovelaceSupply(): Promise<SupplySummary>;
  stake(): Promise<StakeSummary>;
  timeSettings(): Promise<TimeSettings[]>;
}
