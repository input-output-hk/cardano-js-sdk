/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Cardano from '.';
import { AuxiliaryData } from './AuxiliaryData';
import { BlockBodyAlonzo } from '@cardano-ogmios/schema';
import { Hash32ByteBase16, OpaqueString, hexNByte } from '../util';
import { PartialBlockHeader } from './Block';

/**
 * transaction hash as hex string
 */
export type TransactionId = Hash32ByteBase16<'TransactionId'>;

/**
 * @param {string} value transaction hash as hex string
 * @throws InvalidStringError
 */
export const TransactionId = (value: string): TransactionId => Hash32ByteBase16<'TransactionId'>(value);

/**
 * Ed25519 signature as hex string
 */
export type Ed25519Signature = OpaqueString<'Ed25519Signature'>;

/**
 * @param {string} value Ed25519 signature as hex string
 * @throws InvalidStringError
 */
export const Ed25519Signature = (value: string): Ed25519Signature => hexNByte(value, 128);

/**
 * Ed25519 public key as hex string
 */
export type Ed25519PublicKey = OpaqueString<'Ed25519PublicKey'>;

/**
 * @param {string} value Ed25519 public key as hex string
 * @throws InvalidStringError
 */
export const Ed25519PublicKey = (value: string): Ed25519PublicKey => hexNByte(value, 64);

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
  scriptIntegrityHash?: Cardano.Hash28ByteBase16;
  requiredExtraSignatures?: Cardano.Ed25519PublicKey[];
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
  scriptHash: Cardano.Hash28ByteBase16;
  executionUnits: Cardano.ExUnits;
}

export type Witness = Omit<Partial<BlockBodyAlonzo['witness']>, 'redeemers' | 'signatures'> & {
  redeemers?: Redeemer[];
  signatures: Map<Ed25519PublicKey, Ed25519Signature>;
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
