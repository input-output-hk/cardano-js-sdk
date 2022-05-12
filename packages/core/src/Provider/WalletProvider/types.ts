import { Cardano } from '../..';

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

export interface WalletProvider {
  ledgerTip: () => Promise<Cardano.Tip>;
  currentWalletProtocolParameters: () => Promise<ProtocolParametersRequiredByWallet>;
  genesisParameters: () => Promise<Cardano.CompactGenesis>;
}
