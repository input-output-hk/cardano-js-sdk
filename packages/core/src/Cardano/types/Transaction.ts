import * as Cardano from '.';
import { AuxiliaryData } from './AuxiliaryData';
import { BlockBodyAlonzo } from '@cardano-ogmios/schema';
import { OpaqueString, assertIsHexString } from '../util';
import { PartialBlockHeader } from './Block';

/**
 * transaction hash as hex string
 */
export type TransactionId = OpaqueString<'TransactionId'>;

/**
 * @param {string} value transaction hash as hex string
 * @throws InvalidStringError
 */
export const TransactionId = (value: string): TransactionId => {
  assertIsHexString(value, 64);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return value as any as TransactionId;
};

export type Ed25519SignatureHash16 = string;

export interface Withdrawal {
  stakeAddress: Cardano.RewardAccount;
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
