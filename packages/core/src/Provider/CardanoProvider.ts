// Importing types from cardano-serialization-lib-browser will cause TypeScript errors.
import CardanoSerializationLib from '@emurgo/cardano-serialization-lib-nodejs';
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

export interface CardanoProvider {
  ledgerTip: () => Promise<Cardano.Tip>;
  /** @param signedTransaction signed and serialized cbor */
  submitTx: (tx: CardanoSerializationLib.Transaction) => Promise<boolean>;
  utxoDelegationAndRewards: (
    addresses: Cardano.Address[],
    stakeKeyHash: Cardano.Hash16
  ) => Promise<{ utxo: Cardano.Utxo; delegationAndRewards: Cardano.DelegationsAndRewards }>;
  queryTransactionsByAddresses: (addresses: Cardano.Address[]) => Promise<Transaction.WithHash[]>;
  queryTransactionsByHashes: (hashes: Cardano.Hash16[]) => Promise<Transaction.WithHash[]>;
  currentWalletProtocolParameters: () => Promise<ProtocolParametersRequiredByWallet>;
}
