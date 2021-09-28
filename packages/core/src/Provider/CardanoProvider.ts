import { CSL } from '../CSL';
import Cardano, { ProtocolParametersAlonzo } from '@cardano-ogmios/schema';
import { Transaction } from '../';

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

// Todo: Use Cardano.Lovelace when type is updated
type Lovelace = bigint;

export type AssetSupply = {
  circulating: Lovelace;
  max: Lovelace;
  total: Lovelace;
};

export type StakeSummary = {
  active: Lovelace;
  live: Lovelace;
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

export interface CardanoProvider {
  ledgerTip: () => Promise<Cardano.Tip>;
  networkInfo: () => Promise<NetworkInfo>;
  stakePoolStats?: () => Promise<StakePoolStats>;
  /** @param signedTransaction signed and serialized cbor */
  submitTx: (tx: CSL.Transaction) => Promise<boolean>;
  utxoDelegationAndRewards: (
    addresses: Cardano.Address[],
    stakeKeyHash: Cardano.Hash16
  ) => Promise<{ utxo: Cardano.Utxo; delegationAndRewards: Cardano.DelegationsAndRewards }>;
  queryTransactionsByAddresses: (addresses: Cardano.Address[]) => Promise<Transaction.WithHash[]>;
  queryTransactionsByHashes: (hashes: Cardano.Hash16[]) => Promise<Transaction.WithHash[]>;
  currentWalletProtocolParameters: () => Promise<ProtocolParametersRequiredByWallet>;
}
