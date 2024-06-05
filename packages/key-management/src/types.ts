import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, HandleResolution, Serialization, TxCBOR } from '@cardano-sdk/core';
import { HexBlob, OpaqueString, Shutdown } from '@cardano-sdk/util';
import { Logger } from 'ts-log';
import type { Runtime } from 'webextension-polyfill';

export type MessageSender = Runtime.MessageSender;

export interface SignBlobResult {
  publicKey: Crypto.Ed25519PublicKeyHex;
  signature: Crypto.Ed25519SignatureHex;
}

export enum CardanoKeyConst {
  PURPOSE = 1852,
  COIN_TYPE = 1815
}

export enum Cip1852PathLevelIndexes {
  PURPOSE = 0,
  COIN_TYPE = 1,
  ACCOUNT = 2,
  ROLE = 3,
  // address
  INDEX = 4
}

export enum KeyAgentType {
  InMemory = 'InMemory',
  Ledger = 'Ledger',
  Trezor = 'Trezor'
}

export enum KeyRole {
  External = 0,
  Internal = 1,
  Stake = 2,
  DRep = 3
}

export enum KeyPurpose {
  STANDARD = 1852,
  MULTI_SIG = 1854
}

export interface AccountKeyDerivationPath {
  role: KeyRole;
  index: number;
}

/** Internal = change address & External = receipt address */
export enum AddressType {
  /** Change address */
  Internal = 1,
  /** Receipt address */
  External = 0
}

export enum DeviceType {
  Ledger = 'Ledger'
}

export enum CommunicationType {
  Web = 'web',
  Node = 'node'
}

export interface KeyAgentDependencies {
  logger: Logger;
  bip32Ed25519: Crypto.Bip32Ed25519;
}

export interface AccountAddressDerivationPath {
  type: AddressType;
  index: number;
}

export interface GroupedAddress {
  type: AddressType;
  index: number;
  networkId: Cardano.NetworkId;
  accountIndex: number;
  address: Cardano.PaymentAddress;
  rewardAccount: Cardano.RewardAccount;
  stakeKeyDerivationPath?: AccountKeyDerivationPath;
}

export interface TrezorConfig {
  communicationType: CommunicationType;
  silentMode?: boolean;
  lazyLoad?: boolean;
  manifest: {
    email: string;
    appUrl: string;
  };
}

export interface SerializableKeyAgentDataBase {
  chainId: Cardano.ChainId;
  accountIndex: number;
  extendedAccountPublicKey: Crypto.Bip32PublicKeyHex;
  purpose: KeyPurpose;
}

export interface SerializableInMemoryKeyAgentData extends SerializableKeyAgentDataBase {
  __typename: KeyAgentType.InMemory;
  encryptedRootPrivateKeyBytes: number[];
}

export interface SerializableLedgerKeyAgentData extends SerializableKeyAgentDataBase {
  __typename: KeyAgentType.Ledger;
  communicationType: CommunicationType;
}

export interface SerializableTrezorKeyAgentData extends SerializableKeyAgentDataBase {
  __typename: KeyAgentType.Trezor;
  trezorConfig: TrezorConfig;
}

export type SerializableKeyAgentData =
  | SerializableInMemoryKeyAgentData
  | SerializableLedgerKeyAgentData
  | SerializableTrezorKeyAgentData;

export interface KeyPair {
  skey: Crypto.Bip32PrivateKeyHex;
  vkey: Crypto.Bip32PublicKeyHex;
}

export interface Ed25519KeyPair {
  skey: Crypto.Ed25519PrivateNormalKeyHex | Crypto.Ed25519PrivateExtendedKeyHex;
  vkey: Crypto.Ed25519PublicKeyHex;
}

/**
 * @returns passphrase used to decrypt root private key
 */
export type GetPassphrase = (noCache?: true) => Promise<Uint8Array>;

export type TxInId = OpaqueString<'TxInId'>;
export const TxInId = ({ txId, index }: Cardano.TxIn) => `${txId}_${index}` as TxInId;

export type TxInKeyPathMap = Partial<Record<TxInId, AccountKeyDerivationPath>>;
export type RewardAccountKeyPathMap = Partial<Record<Cardano.RewardAccount, AccountKeyDerivationPath>>;
export type KeyHashKeyPathMap = Partial<Record<Crypto.Ed25519KeyHashHex, AccountKeyDerivationPath>>;

/** The result of the transaction signer signing operation. */
export type TransactionSignerResult = {
  /** The public key matching the private key that generate the signature. */
  pubKey: Crypto.Ed25519PublicKeyHex;

  /** The transaction signature. */
  signature: Crypto.Ed25519SignatureHex;
};

/** Produces a Ed25519Signature of a transaction. */
export interface TransactionSigner {
  /**
   * Sings a transaction.
   *
   * @param tx The transaction to be signed.
   * @returns A Ed25519 transaction signature.
   */
  sign(tx: Cardano.TxBodyWithHash): Promise<TransactionSignerResult>;
}

export interface SignTransactionOptions {
  additionalKeyPaths?: AccountKeyDerivationPath[];
  extraSigners?: TransactionSigner[];
  stubSign?: boolean;
}

export interface SignTransactionContext {
  txInKeyPathMap: TxInKeyPathMap;
  knownAddresses: GroupedAddress[];
  handleResolutions?: HandleResolution[];
  purpose: KeyPurpose;
  dRepPublicKey?: Crypto.Ed25519PublicKeyHex;
  sender?: MessageSender;
}

export interface SignDataContext {
  address?: Cardano.PaymentAddress | Cardano.RewardAccount | Cardano.DRepID;
  /** Present when signing CIP-0008 structure */
  payload?: HexBlob;
  sender?: MessageSender;
}

export interface KeyAgent {
  get chainId(): Cardano.ChainId;
  get accountIndex(): number;
  get purpose(): KeyPurpose;
  get serializableData(): SerializableKeyAgentData;
  get extendedAccountPublicKey(): Crypto.Bip32PublicKeyHex;
  get bip32Ed25519(): Crypto.Bip32Ed25519;

  /**
   * @throws AuthenticationError
   */
  signBlob(derivationPath: AccountKeyDerivationPath, blob: HexBlob): Promise<SignBlobResult>;
  /**
   * @throws AuthenticationError
   */
  signTransaction(
    txInternals: Cardano.TxBodyWithHash,
    context: SignTransactionContext,
    options?: SignTransactionOptions
  ): Promise<Cardano.Signatures>;
  /**
   * @throws AuthenticationError
   */
  derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Crypto.Ed25519PublicKeyHex>;

  /**
   * Derives an address from the given payment key and stake key derivation path.
   *
   * @param paymentKeyDerivationPath The payment key derivation path.
   * @param stakeKeyDerivationIndex The stake key index. This field is optional. If not provided it defaults to index 0.
   */
  deriveAddress(
    paymentKeyDerivationPath: AccountAddressDerivationPath,
    stakeKeyDerivationIndex: number
  ): Promise<GroupedAddress>;
  /**
   * @throws AuthenticationError
   */
  exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex>;
}

export type AsyncKeyAgent = Pick<KeyAgent, 'deriveAddress' | 'derivePublicKey' | 'signBlob' | 'signTransaction'> & {
  getChainId(): Promise<Cardano.ChainId>;
  getBip32Ed25519(): Promise<Crypto.Bip32Ed25519>;
  getExtendedAccountPublicKey(): Promise<Crypto.Bip32PublicKeyHex>;
  getAccountIndex(): Promise<number>;
  getKeyPurpose(): Promise<KeyPurpose>;
} & Shutdown;

export type WitnessOptions = SignTransactionOptions;

export interface WitnessedTx {
  cbor: TxCBOR;
  tx: Cardano.Tx;
  context: {
    handleResolutions: HandleResolution[];
  };
}

/** Interface for an entity capable of generating witness data for a transaction. */
export interface Witnesser {
  /**
   * Generates the witness data for a given transaction.
   *
   * @param transaction The transaction along with its hash for which the witness data is to be generated.
   * @param context The witness sign transaction context
   * @param options Optional additional parameters that may influence how the witness data is generated.
   * @returns A promise that resolves to the transaction with the generated witness data.
   */
  witness(
    transaction: Serialization.Transaction,
    context: SignTransactionContext,
    options?: WitnessOptions
  ): Promise<WitnessedTx>;

  /**
   * @throws AuthenticationError
   */
  signBlob(derivationPath: AccountKeyDerivationPath, blob: HexBlob, context: SignDataContext): Promise<SignBlobResult>;
}
