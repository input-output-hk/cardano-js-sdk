import { AnyWallet, HardwareWallet, InMemoryWallet, ScriptWallet, WalletId } from '../types';
import { Observable } from 'rxjs';

export type RemoveAccountProps = {
  walletId: WalletId;
  /** account' in cip1852 */
  accountIndex: number;
};

export type AddAccountProps<Metadata extends {}> = {
  walletId: WalletId;
  /** account' in cip1852 */
  accountIndex: number;
  metadata: Metadata;
};

export type UpdateWalletMetadataProps<Metadata extends {}> = {
  walletId: WalletId;
  metadata: Metadata;
};

export type UpdateAccountMetadataProps<Metadata extends {}> = {
  /** account' in cip1852; must be specified for bip32 wallets */
  walletId: WalletId;
  accountIndex: number;
  metadata: Metadata;
};

export type AddWalletProps<WalletMetadata extends {}, AccountMetadata extends {}> =
  | Omit<HardwareWallet<WalletMetadata, AccountMetadata>, 'walletId' | 'accounts'>
  | Omit<InMemoryWallet<WalletMetadata, AccountMetadata>, 'walletId' | 'accounts'>
  | Omit<ScriptWallet<WalletMetadata>, 'walletId'>;

export interface WalletRepositoryApi<WalletMetadata extends {}, AccountMetadata extends {}> {
  wallets$: Observable<AnyWallet<WalletMetadata, AccountMetadata>[]>;

  /** Rejects with WalletConflictError when wallet already exists */
  addWallet(props: AddWalletProps<WalletMetadata, AccountMetadata>): Promise<WalletId>;

  /**
   * Can be used to add a new account to an existing BIP32Wallet
   *
   * Rejects with WalletConflictError when either
   * - wallet with provided `walletId` is not found
   * - account already exists for this wallet
   */
  addAccount(props: AddAccountProps<AccountMetadata>): Promise<AddAccountProps<AccountMetadata>>;

  /** Rejects with WalletConflictError when wallet or account with specified index is not found */
  updateWalletMetadata(
    props: UpdateWalletMetadataProps<WalletMetadata>
  ): Promise<UpdateWalletMetadataProps<WalletMetadata>>;

  updateAccountMetadata(
    props: UpdateWalletMetadataProps<AccountMetadata>
  ): Promise<UpdateWalletMetadataProps<AccountMetadata>>;

  /** Rejects with WalletConflictError when account is not found. */
  removeAccount(props: RemoveAccountProps): Promise<RemoveAccountProps>;

  /** Rejects with WalletConflictError when wallet is not found. */
  removeWallet(walletId: WalletId): Promise<WalletId>;
}
