import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { HexBlob, Shutdown } from '@cardano-sdk/util';
import { Logger } from 'ts-log';
import { Observable } from 'rxjs';
import TransportNodeHid from '@ledgerhq/hw-transport-node-hid-noevents';
import TransportWebHID from '@ledgerhq/hw-transport-webhid';

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
  Stake = 2
}

export interface AccountKeyDerivationPath {
  role: KeyRole;
  index: number;
}
/** Internal = change address & External = receipt address */
export enum AddressType {
  /**
   * Change address
   */
  Internal = 1,
  /**
   * Receipt address
   */
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
  inputResolver: Cardano.util.InputResolver;
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
  address: Cardano.Address;
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
  knownAddresses: GroupedAddress[];
  extendedAccountPublicKey: Crypto.Bip32PublicKeyHex;
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

export type LedgerTransportType = TransportWebHID | TransportNodeHid;

export interface KeyPair {
  skey: Crypto.Bip32PrivateKeyHex;
  vkey: Crypto.Bip32PublicKeyHex;
}

export interface Ed25519KeyPair {
  skey: Crypto.Ed25519PrivateNormalKeyHex | Crypto.Ed25519PrivateExtendedKeyHex;
  vkey: Crypto.Ed25519PublicKeyHex;
}

/**
 * @returns password used to decrypt root private key
 */
export type GetPassword = (noCache?: true) => Promise<Uint8Array>;

export interface SignTransactionOptions {
  additionalKeyPaths?: AccountKeyDerivationPath[];
}

export interface KeyAgent {
  get chainId(): Cardano.ChainId;
  get accountIndex(): number;
  get serializableData(): SerializableKeyAgentData;
  get knownAddresses(): GroupedAddress[];
  get extendedAccountPublicKey(): Crypto.Bip32PublicKeyHex;
  get bip32Ed25519(): Crypto.Bip32Ed25519;
  /**
   * @throws AuthenticationError
   */
  signBlob(derivationPath: AccountKeyDerivationPath, blob: HexBlob): Promise<SignBlobResult>;
  /**
   * @throws AuthenticationError
   */
  signTransaction(txInternals: Cardano.TxBodyWithHash, options?: SignTransactionOptions): Promise<Cardano.Signatures>;
  /**
   * @throws AuthenticationError
   */
  derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Crypto.Ed25519PublicKeyHex>;
  /**
   * @throws AuthenticationError
   */
  deriveAddress(derivationPath: AccountAddressDerivationPath): Promise<GroupedAddress>;
  /**
   * @throws AuthenticationError
   */
  exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex>;
}

export type AsyncKeyAgent = Pick<KeyAgent, 'deriveAddress' | 'derivePublicKey' | 'signBlob' | 'signTransaction'> & {
  knownAddresses$: Observable<GroupedAddress[]>;
  getChainId(): Promise<Cardano.ChainId>;
  getBip32Ed25519(): Promise<Crypto.Bip32Ed25519>;
  getExtendedAccountPublicKey(): Promise<Crypto.Bip32PublicKeyHex>;
} & Shutdown;

/**
 * The result of the transaction signer signing operation.
 */
export type TransactionSignerResult = {
  /**
   * The public key matching the private key that generate the signature.
   */
  pubKey: Crypto.Ed25519PublicKeyHex;

  /**
   * The transaction signature.
   */
  signature: Crypto.Ed25519SignatureHex;
};

/**
 * Produces a Ed25519Signature of a transaction.
 */
export interface TransactionSigner {
  /**
   * Sings a transaction.
   *
   * @param tx The transaction to be signed.
   * @returns A Ed25519 transaction signature.
   */
  sign(tx: Cardano.TxBodyWithHash): Promise<TransactionSignerResult>;
}
