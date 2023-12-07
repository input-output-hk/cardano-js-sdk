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

export type UpdateMetadataProps<Metadata extends {}> = {
  walletId: WalletId;
  /** account' in cip1852; must be specified for bip32 wallets */
  accountIndex?: number;
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
  addAccount(props: AddAccountProps<Metadata>): Promise<AddAccountProps<Metadata>>;

  /** Rejects with WalletConflictError when wallet or account with specified index is not found */
  updateMetadata(props: UpdateMetadataProps<Metadata>): Promise<UpdateMetadataProps<Metadata>>;

  /** Rejects with WalletConflictError when account is not found. */
  removeAccount(props: RemoveAccountProps): Promise<RemoveAccountProps>;

  /** Rejects with WalletConflictError when wallet is not found. */
  removeWallet(walletId: WalletId): Promise<WalletId>;
}
