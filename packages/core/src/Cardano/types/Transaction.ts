/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Cardano from '.';
import * as Ogmios from '@cardano-ogmios/schema';
import { AuxiliaryData } from './AuxiliaryData';
import { Ed25519PublicKey } from './Key';
import { Hash32ByteBase16, HexBlob, OpaqueString, typedHex } from '../util';
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
TransactionId.fromHexBlob = (value: HexBlob) => Hash32ByteBase16.fromHexBlob<TransactionId>(value);

/**
 * Ed25519 signature as hex string
 */
export type Ed25519Signature = OpaqueString<'Ed25519Signature'>;

/**
 * @param {string} value Ed25519 signature as hex string
 * @throws InvalidStringError
 */
export const Ed25519Signature = (value: string): Ed25519Signature => typedHex(value, 128);

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
  scriptIntegrityHash?: Cardano.Hash32ByteBase16;
  requiredExtraSignatures?: Cardano.Ed25519KeyHash[];
}

export interface NewTxBodyAlonzo extends Omit<TxBodyAlonzo, 'inputs' | 'collaterals'> {
  inputs: Cardano.NewTxIn[];
  collaterals?: Cardano.NewTxIn[];
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

export enum RedeemerPurpose {
  spend = 'spend',
  mint = 'mint',
  certificate = 'certificate',
  withdrawal = 'withdrawal'
}

export interface Redeemer {
  index: number;
  purpose: RedeemerPurpose;
  scriptHash: Cardano.Hash28ByteBase16;
  executionUnits: Cardano.ExUnits;
}

export type Signatures = Map<Ed25519PublicKey, Ed25519Signature>;

export type Witness = Omit<Partial<Ogmios.TxAlonzo['witness']>, 'redeemers' | 'signatures'> & {
  redeemers?: Redeemer[];
  signatures: Signatures;
};

export interface NewTxAlonzo<TBody extends NewTxBodyAlonzo = NewTxBodyAlonzo> {
  id: TransactionId;
  body: TBody;
  witness: Witness;
  auxiliaryData?: AuxiliaryData;
}

export interface TxAlonzo extends NewTxAlonzo<TxBodyAlonzo> {
  index: number;
  blockHeader: PartialBlockHeader;
  body: TxBodyAlonzo;
  implicitCoin: ImplicitCoin;
  txSize: number;
}
