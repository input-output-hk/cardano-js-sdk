import { AccountId, AnyWallet, HardwareWallet, InMemoryWallet, ScriptWallet, WalletId } from '../types';
import { Observable } from 'rxjs';

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
