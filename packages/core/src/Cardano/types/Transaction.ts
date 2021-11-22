import * as Cardano from '.';
import { AuxiliaryData } from './AuxiliaryData';
import { BlockAlonzo, BlockBodyAlonzo } from '@cardano-ogmios/schema';

type OgmiosHeader = NonNullable<BlockAlonzo['header']>;
export type PartialBlockHeader = Pick<OgmiosHeader, 'blockHeight' | 'slot' | 'blockHash'>;
export type TransactionId = Cardano.Hash16;

export type Ed25519SignatureHash16 = string;

export interface Withdrawal {
  stakeAddress: Cardano.Address;
  quantity: Cardano.Lovelace;
}
export interface TxBodyAlonzo {
  inputs: Cardano.TxIn[];
  collaterals?: Cardano.TxIn[];
  outputs: Cardano.TxOut[];
  fee: Cardano.Lovelace;
  validityInterval: Cardano.ValidityInterval;
  withdrawals?: Withdrawal[];
  certificates?: Cardano.Certificate[];
  mint?: Cardano.TokenMap;
  scriptIntegrityHash?: Cardano.Hash16;
  requiredExtraSignatures?: Cardano.Hash16[];
}

/**
 * Implicit coin quantities used in the transaction
 */
export interface ImplicitCoin {
  /**
   * Reward withdrawals + deposit reclaims
   */
  input?: Cardano.Lovelace;
  /**
   * Delegation registration deposit
   */
  deposit?: Cardano.Lovelace;
}

export interface Redeemer {
  index: number;
  purpose: 'spend' | 'mint' | 'certificate' | 'withdrawal';
  scriptHash: Cardano.Hash64;
  executionUnits: Cardano.ExUnits;
}

export type Witness = Omit<Partial<BlockBodyAlonzo['witness']>, 'redeemers' | 'signatures'> & {
  redeemers?: Redeemer[];
  signatures: Partial<{
    [k: string]: Ed25519SignatureHash16;
  }>;
};

export interface TxAlonzo {
  id: TransactionId;
  index: number;
  blockHeader: PartialBlockHeader;
  body: TxBodyAlonzo;
  implicitCoin: ImplicitCoin;
  txSize: number;
  witness: Witness;
  auxiliaryData?: AuxiliaryData;
}

export type NewTxAlonzo = Omit<TxAlonzo, 'blockHeader' | 'implicitCoin' | 'txSize' | 'index'>;
