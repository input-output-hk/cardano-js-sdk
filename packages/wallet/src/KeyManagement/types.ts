import { Cardano } from '@cardano-sdk/core';
import { TxInternals } from '../Transaction';

export type HexBlob = Cardano.util.OpaqueString<'HexBlob'>;
export const HexBlob = (target: string): HexBlob => Cardano.util.typedHex(target);

export interface SignBlobResult {
  publicKey: Cardano.Ed25519PublicKey;
  signature: Cardano.Ed25519Signature;
}

export enum KeyAgentType {
  InMemory = 'InMemory'
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

export type SerializableKeyAgentData = SerializableInMemoryKeyAgentData;

/**
 * @returns password used to decrypt root private key
 */
export type GetPassword = (noCache?: true) => Promise<Uint8Array>;

export interface KeyAgent {
  get networkId(): Cardano.NetworkId;
  get accountIndex(): number;
  get serializableData(): SerializableKeyAgentData;
  /**
   * @throws AuthenticationError
   */
  getExtendedAccountPublicKey(): Promise<Cardano.Bip32PublicKey>;
  /**
   * @throws AuthenticationError
   */
  signBlob(derivationPath: AccountKeyDerivationPath, blob: HexBlob): Promise<SignBlobResult>;
  /**
   * @throws AuthenticationError
   */
  signTransaction(txInternals: TxInternals): Promise<Cardano.Signatures>;
  /**
   * @throws AuthenticationError
   */
  derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Cardano.Ed25519PublicKey>;
  /**
   * @throws AuthenticationError
   */
  deriveAddress(derivationPath: AccountAddressDerivationPath): Promise<GroupedAddress>;
  /**
   * @throws AuthenticationError
   */
  exportRootPrivateKey(): Promise<Cardano.Bip32PrivateKey>;
}
