import { AccountKeyDerivationPath, KeyPurpose } from '@cardano-sdk/key-management';
import { Bip32PublicKeyHex } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';

export enum WalletType {
  InMemory = 'InMemory',
  Ledger = 'Ledger',
  Trezor = 'Trezor',
  Script = 'Script'
}

/** For BIP-32 wallets: hash of extended account public key. For script wallets: script hash */
export type WalletId = string;

export type Bip32WalletAccount<Metadata extends {}> = {
  accountIndex: number;
  purpose?: KeyPurpose;
  /** e.g. account name, picture */
  metadata: Metadata;
  extendedAccountPublicKey: Bip32PublicKeyHex;
};

export type Bip32Wallet<WalletMetadata extends {}, AccountMetadata extends {}> = {
  walletId: WalletId;
  metadata: WalletMetadata;
  accounts: Bip32WalletAccount<AccountMetadata>[];
};

export type HardwareWallet<WalletMetadata extends {}, AccountMetadata extends {}> = Bip32Wallet<
  WalletMetadata,
  AccountMetadata
> & {
  type: WalletType.Ledger | WalletType.Trezor;
};

export type InMemoryWallet<WalletMetadata extends {}, AccountMetadata extends {}> = Bip32Wallet<
  WalletMetadata,
  AccountMetadata
> & {
  type: WalletType.InMemory;
  encryptedSecrets: {
    /**
     * The key material is derived by concatenating the mnemonic words (separated by spaces) into a single string.
     * This concatenated string is then encrypted using the 'emip3encrypt' method. The resulting
     * encrypted data is encoded as a hexadecimal string.
     */
    keyMaterial: HexBlob;
    rootPrivateKeyBytes: HexBlob;
  };
};

export type AnyBip32Wallet<WalletMetadata extends {}, AccountMetadata extends {}> =
  | HardwareWallet<WalletMetadata, AccountMetadata>
  | InMemoryWallet<WalletMetadata, AccountMetadata>;

export type OwnSignerAccount = {
  walletId: WalletId;
  purpose: KeyPurpose;
  accountIndex: number;
  stakingScriptKeyPath: AccountKeyDerivationPath;
  paymentScriptKeyPath: AccountKeyDerivationPath;
};

export type ScriptWallet<Metadata extends {}> = {
  type: WalletType.Script;
  walletId: WalletId;
  /** e.g. account name, picture */
  metadata: Metadata;
  paymentScript: Cardano.Script;
  stakingScript: Cardano.Script;
  ownSigners: OwnSignerAccount[];
};

export type AnyWallet<WalletMetadata extends {}, AccountMetadata extends {}> =
  | HardwareWallet<WalletMetadata, AccountMetadata>
  | InMemoryWallet<WalletMetadata, AccountMetadata>
  | ScriptWallet<WalletMetadata>;
