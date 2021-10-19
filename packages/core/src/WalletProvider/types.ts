import Cardano, { ProtocolParametersAlonzo } from '@cardano-ogmios/schema';
import { Ogmios, Transaction, CSL } from '..';

export type ProtocolParametersRequiredByWallet = Pick<
  ProtocolParametersAlonzo,
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
>;

export type AssetSupply = {
  circulating: Ogmios.Lovelace;
  max: Ogmios.Lovelace;
  total: Ogmios.Lovelace;
};

export type StakeSummary = {
  active: Ogmios.Lovelace;
  live: Ogmios.Lovelace;
};

export type StakePoolStats = {
  qty: {
    active: number;
    retired: number;
    retiring: number;
  };
};

export type NetworkInfo = {
  currentEpoch: {
    number: Cardano.Epoch;
    start: {
      /** Local date */
      date: Date;
    };
    end: {
      /** Local date */
      date: Date;
    };
  };
  lovelaceSupply: AssetSupply;
  stake: StakeSummary;
};

export interface WalletProvider {
  ledgerTip: () => Promise<Cardano.Tip>;
  networkInfo: () => Promise<NetworkInfo>;
  stakePoolStats?: () => Promise<StakePoolStats>;
  /** @param signedTransaction signed and serialized cbor */
  submitTx: (signedTransaction: CSL.Transaction) => Promise<void>;
  utxoDelegationAndRewards: (
    addresses: Cardano.Address[],
    stakeKeyHash: Cardano.Hash16
  ) => Promise<{ utxo: Cardano.Utxo; delegationAndRewards: Cardano.DelegationsAndRewards }>;
  queryTransactionsByAddresses: (addresses: Cardano.Address[]) => Promise<Transaction.WithHash[]>;
  queryTransactionsByHashes: (hashes: Cardano.Hash16[]) => Promise<Transaction.WithHash[]>;
  currentWalletProtocolParameters: () => Promise<ProtocolParametersRequiredByWallet>;
}
