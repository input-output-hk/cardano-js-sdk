import { Bip32PublicKeyHex, Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { Observable } from 'rxjs';

export enum WalletType {
  InMemory = 'InMemory',
  Ledger = 'Ledger',
  Trezor = 'Trezor',
  Script = 'Script'
}

/** For BIP-32 wallets: hash of extended account public key. For script wallets: script hash */
export type WalletId = Hash28ByteBase16;

/** walletId+accountIndex (only applicable for bip32 wallets) */
export type AccountId = string;

export type Bip32WalletAccount<Metadata extends {}> = {
  accountId: AccountId;
  /** account' in cip1852 */
  accountIndex: number;
  /** e.g. account name, picture */
  metadata: Metadata;
};

export type Bip32Wallet<Metadata extends {}> = {
  walletId: WalletId;
  extendedAccountPublicKey: Bip32PublicKeyHex;
  accounts: Bip32WalletAccount<Metadata>[];
};

export type HardwareWallet<Metadata extends {}> = Bip32Wallet<Metadata> & {
  type: WalletType.Ledger | WalletType.Trezor;
};

export type InMemoryWallet<Metadata extends {}> = Bip32Wallet<Metadata> & {
  type: WalletType.InMemory;
  encryptedSecrets: {
    entropy: HexBlob;
    rootPrivateKeyBytes: HexBlob;
  };
};

export type OwnSignerAccount = {
  walletId: WalletId;
  accountId: AccountId;
};

export type ScriptWallet<Metadata extends {}> = {
  type: WalletType.Script;
  walletId: WalletId;
  /** e.g. account name, picture */
  metadata: Metadata;
  script: Cardano.Script;
  ownSigners: OwnSignerAccount[];
};

export type AnyWallet<Metadata extends {}> =
  | HardwareWallet<Metadata>
  | InMemoryWallet<Metadata>
  | ScriptWallet<Metadata>;

export type AddAccountProps<Metadata extends {}> = {
  walletId: WalletId;
  /** account' in cip1852 */
  accountIndex: number;
  metadata: Metadata;
};

export type UpdateMetadataProps<Metadata extends {}, ID extends AccountId | WalletId> = {
  target: ID;
  metadata: Metadata;
};

export type AddWalletProps<Metadata extends {}> =
  | Omit<HardwareWallet<Metadata>, 'walletId' | 'accounts'>
  | Omit<InMemoryWallet<Metadata>, 'walletId' | 'accounts'>
  | Omit<ScriptWallet<Metadata>, 'walletId'>;

export interface WalletRepositoryApi<Metadata extends {}> {
  wallets$: Observable<AnyWallet<Metadata>[]>;

  /** Rejects with WalletConflictError when wallet already exists */
  addWallet(props: AddWalletProps<Metadata>): Promise<WalletId>;

  /**
   * Can be used to add a new account to an existing BIP32Wallet
   *
   * Rejects with WalletConflictError when either
   * - wallet with provided `walletId` is not found
   * - account already exists for this wallet
   */
  addAccount(props: AddAccountProps<Metadata>): Promise<AccountId>;

  /** Rejects with WalletConflictError when wallet or account with specified id is not found */
  updateMetadata<ID extends WalletId | AccountId>(props: UpdateMetadataProps<Metadata, ID>): Promise<ID>;

  /** Rejects with WalletConflictError when account is not found. */
  removeAccount(accountId: AccountId): Promise<AccountId>;

  /** Rejects with WalletConflictError when wallet is not found. */
  removeWallet(walletId: WalletId): Promise<WalletId>;
}
