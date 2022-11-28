/* eslint-disable @typescript-eslint/no-explicit-any */
import { AuxiliaryData } from './AuxiliaryData';
import { Base64Blob, Hash28ByteBase16, Hash32ByteBase16, HexBlob, OpaqueString, typedHex } from '../util/primitives';
import { Certificate } from './Certificate';
import { Datum, Script } from './Script';
import { Ed25519KeyHash, Ed25519PublicKey } from './Key';
import { ExUnits, ValidityInterval } from './ProtocolParameters';
import { Lovelace, TokenMap } from './Value';
import { NewTxIn, TxIn, TxOut } from './Utxo';
import { PartialBlockHeader } from './Block';
import { RewardAccount } from './RewardAccount';

/**
 * transaction hash as hex string
 */
export type TransactionId = OpaqueString<'TransactionId'>;

/**
 * @param {string} value transaction hash as hex string
 * @throws InvalidStringError
 */
export const TransactionId = (value: string): TransactionId => Hash32ByteBase16(value) as unknown as TransactionId;
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
  stakeAddress: RewardAccount;
  quantity: Lovelace;
}

export interface TxBodyAlonzo {
  inputs: TxIn[];
  collaterals?: TxIn[];
  outputs: TxOut[];
  fee: Lovelace;
  validityInterval?: ValidityInterval;
  withdrawals?: Withdrawal[];
  certificates?: Certificate[];
  mint?: TokenMap;
  scriptIntegrityHash?: Hash32ByteBase16;
  requiredExtraSignatures?: Ed25519KeyHash[];
}

export interface NewTxBodyAlonzo extends Omit<TxBodyAlonzo, 'inputs' | 'collaterals'> {
  inputs: NewTxIn[];
  collaterals?: NewTxIn[];
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
  scriptHash: Hash28ByteBase16;
  executionUnits: ExUnits;
}

export type Signatures = Map<Ed25519PublicKey, Ed25519Signature>;

export type Signature = Ed25519Signature;
export type ChainCode = HexBlob;
export type AddressAttributes = Base64Blob;
export type VerificationKey = Ed25519PublicKey;

export interface BootstrapWitness {
  signature?: Signature;
  chainCode?: ChainCode;
  addressAttributes?: AddressAttributes;
  key?: VerificationKey;
}

export type Witness = {
  redeemers?: Redeemer[];
  signatures: Signatures;
  scripts?: Script[];
  bootstrap?: BootstrapWitness[];
  datums?: Datum[];
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
  txSize: number;
}

export type TxBodyWithHash = {
  hash: TransactionId;
  body: NewTxBodyAlonzo;
};
