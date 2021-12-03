import { Cardano } from '@cardano-sdk/core';
import { TxInternals } from '../Transaction';

// TODO: test
export type HexBlob = Cardano.util.OpaqueString<'HexBlob'>;
export const HexBlob = (target: string): HexBlob => Cardano.util.typedHex(target);

// TODO: convert to hex opaque string type and possibly move to core
export type Bip32PublicKey = string;
export type Bip32PrivateKey = string;

export interface SignBlobResult {
  publicKey: Cardano.Ed25519PublicKey;
  signature: Cardano.Ed25519Signature;
}

export enum KeyAgentType {
  InMemory = 'InMemory',
  Ledger = 'Ledger'
}

export enum KeyType {
  External = 0,
  Internal = 1,
  Stake = 2
}

export interface AccountKeyDerivationPath {
  type: KeyType;
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
}

/**
 * number[] is used by InMemoryKeyAgent
 */
export type AgentSpecificData = number[] | null;

export interface SerializableKeyAgentDataBase {
  networkId: Cardano.NetworkId;
  accountIndex: number;
}

export interface SerializableInMemoryKeyAgentData extends SerializableKeyAgentDataBase {
  __typename: KeyAgentType.InMemory;
  encryptedRootPrivateKeyBytes: number[];
}

export interface SerializableLedgerKeyAgentData extends SerializableKeyAgentDataBase {
  __typename: KeyAgentType.Ledger;
}

export type SerializableKeyAgentData = SerializableInMemoryKeyAgentData | SerializableLedgerKeyAgentData;

// TODO: utility to cache password for specified duration
/**
 * @returns password used to decrypt root private key
 */
export type GetPassword = (noCache?: true) => Promise<Uint8Array>;

export interface KeyAgent {
  get networkId(): Cardano.NetworkId;
  get accountIndex(): number;
  get serializableData(): SerializableKeyAgentData;
  getExtendedAccountPublicKey(): Promise<Bip32PublicKey>;
  signBlob(derivationPath: AccountKeyDerivationPath, blob: HexBlob): Promise<SignBlobResult>;
  signTransaction(txInternals: TxInternals): Promise<Cardano.Witness['signatures']>;
  derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Cardano.Ed25519PublicKey>;
  deriveAddress(derivationPath: AccountAddressDerivationPath): Promise<GroupedAddress>;
  exportRootPrivateKey(): Promise<Bip32PrivateKey>;
}
