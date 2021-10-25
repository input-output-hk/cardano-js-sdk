import OgmiosSchema, { ProtocolParametersAlonzo } from '@cardano-ogmios/schema';
import { Ogmios, Transaction, CSL, Cardano } from '..';

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
    number: OgmiosSchema.Epoch;
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
  ledgerTip: () => Promise<OgmiosSchema.Tip>;
  networkInfo: () => Promise<NetworkInfo>;
  // TODO: move stakePoolStats out to other provider type, since it's not required for wallet operation
  stakePoolStats?: () => Promise<StakePoolStats>;
  /** @param signedTransaction signed and serialized cbor */
  submitTx: (signedTransaction: CSL.Transaction) => Promise<void>;
  // TODO: split utxoDelegationAndRewards this into 2 or 3 functions
  utxoDelegationAndRewards: (
    addresses: OgmiosSchema.Address[],
    stakeKeyHash: OgmiosSchema.Hash16
  ) => Promise<{ utxo: Cardano.Utxo[]; delegationAndRewards: OgmiosSchema.DelegationsAndRewards }>;
  transactionDetails: (hash: OgmiosSchema.Hash16) => Promise<Transaction.TxDetails>;
  /**
   * TODO: add an optional 'since: Slot' argument for querying transactions and utxos.
   * When doing so we need to also consider how best we can use the volatile block range of the chain
   * to minimise over-fetching and assist the application in handling rollback scenarios.
   */
  queryTransactionsByAddresses: (addresses: OgmiosSchema.Address[]) => Promise<Transaction.Tx[]>;
  queryTransactionsByHashes: (hashes: OgmiosSchema.Hash16[]) => Promise<Transaction.Tx[]>;
  currentWalletProtocolParameters: () => Promise<ProtocolParametersRequiredByWallet>;
}
