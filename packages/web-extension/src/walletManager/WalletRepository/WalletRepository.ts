import {
  AddAccountProps,
  AddWalletProps,
  RemoveAccountProps,
  UpdateAccountMetadataProps,
  UpdateWalletMetadataProps,
  WalletRepositoryApi
} from './types';
import { AnyWallet, ScriptWallet, WalletId, WalletType } from '../types';
import { Logger } from 'ts-log';
import { Observable, defer, firstValueFrom, map, shareReplay, switchMap, take } from 'rxjs';
import { WalletConflictError } from '../errors';
import { contextLogger } from '@cardano-sdk/util';
import { getWalletId } from '../util';
import { storage } from '@cardano-sdk/wallet';

export interface WalletRepositoryDependencies<WalletMetadata extends {}, AccountMetadata extends {}> {
  store: storage.CollectionStore<AnyWallet<WalletMetadata, AccountMetadata>>;
  logger: Logger;
}

const cloneSplice = <T>(array: T[], start: number, deleteCount: number, ...items: T[]) => [
  ...array.slice(0, start),
  ...items,
  ...array.slice(start + deleteCount)
];

const findAccount = <WalletMetadata extends {}, AccountMetadata extends {}>(
  wallets: AnyWallet<WalletMetadata, AccountMetadata>[],
  walletId: WalletId,
  accountIndex: number
) => {
  const walletIdx = wallets.findIndex((w) => w.walletId === walletId);
  const wallet = wallets[walletIdx];
  if (!wallet || wallet.type === WalletType.Script) return;
  const accountIdx = wallet.accounts.findIndex((acc) => acc.accountIndex === accountIndex);
  if (accountIdx < 0) return;
  return {
    account: wallet.accounts[accountIdx],
    accountIdx,
    wallet,
    walletIdx
  };
};

export class WalletRepository<WalletMetadata extends {}, AccountMetadata extends {}>
  implements WalletRepositoryApi<WalletMetadata, AccountMetadata>
{
  readonly #logger: Logger;
  readonly #store: WalletRepositoryDependencies<WalletMetadata, AccountMetadata>['store'];
  readonly wallets$: Observable<AnyWallet<WalletMetadata, AccountMetadata>[]>;

  constructor({ logger, store }: WalletRepositoryDependencies<WalletMetadata, AccountMetadata>) {
    this.#store = store;
    this.#logger = contextLogger(logger, 'WalletRepository');
    this.wallets$ = defer(() => store.observeAll()).pipe(shareReplay(1));
  }

  #getWallets() {
    return this.wallets$.pipe(
      // `setAll` makes the store.observeAll source emit
      // so the pipes are triggered twice otherwise
      take(1)
    );
  }

  async addWallet(props: AddWalletProps<WalletMetadata, AccountMetadata>): Promise<WalletId> {
    this.#logger.debug('addWallet', props.type);
    const walletId =
      props.type === WalletType.Script
        ? await getWalletId(props.paymentScript)
        : await (() => {
            const pubKey = props.accounts[0]?.extendedAccountPublicKey;
            if (!pubKey) {
              throw new WalletConflictError('New wallet must have at least one account');
            }
            return getWalletId(pubKey);
          })();

    return firstValueFrom(
      this.#getWallets().pipe(
        switchMap((wallets) => {
          if (wallets.some((wallet) => wallet.walletId === walletId)) {
            throw new WalletConflictError(`Wallet '${walletId}' already exists`);
          }
          if (props.type === WalletType.Script) {
            this.#validateOwnSigners(wallets, props.ownSigners);
          }
          return this.#store.setAll([...wallets, { ...props, walletId }]);
        }),
        map(() => walletId)
      )
    );
  }

  addAccount(props: AddAccountProps<AccountMetadata>): Promise<AddAccountProps<AccountMetadata>> {
    const { walletId, accountIndex, metadata, extendedAccountPublicKey } = props;
    this.#logger.debug('addAccount', walletId, accountIndex, metadata);
    return firstValueFrom(
      this.#getWallets().pipe(
        switchMap((wallets) => {
          const walletIndex = wallets.findIndex((w) => w.walletId === walletId);
          if (walletIndex < 0) {
            throw new WalletConflictError(`Wallet '${walletId}' does not exist`);
          }
          const wallet = wallets[walletIndex];
          if (wallet.type === WalletType.Script) {
            throw new WalletConflictError('addAccount for script wallets is not supported');
          }
          if (wallet.accounts.some((acc) => acc.accountIndex === accountIndex)) {
            throw new WalletConflictError(`Account #${accountIndex} for wallet '${walletId}' already exists`);
          }

          return this.#store
            .setAll(
              cloneSplice(wallets, walletIndex, 1, {
                ...wallet,
                accounts: [
                  ...wallet.accounts,
                  {
                    accountIndex,
                    extendedAccountPublicKey,
                    metadata
                  }
                ]
              })
            )
            .pipe(map(() => props));
        })
      )
    );
  }

  updateWalletMetadata(
    props: UpdateWalletMetadataProps<WalletMetadata>
  ): Promise<UpdateWalletMetadataProps<WalletMetadata>> {
    const { walletId, metadata } = props;
    this.#logger.debug('updateWalletMetadata', walletId, metadata);
    return firstValueFrom(
      this.#getWallets().pipe(
        switchMap((wallets) => {
          const walletIndex = wallets.findIndex((wallet) => wallet.walletId === walletId);
          if (walletIndex >= 0) {
            // update any wallet
            return this.#store.setAll(
              cloneSplice(wallets, walletIndex, 1, {
                ...(wallets[walletIndex] as AnyWallet<WalletMetadata, AccountMetadata>),
                metadata
              })
            );
          }
          throw new WalletConflictError(`Wallet not found: ${walletId}`);
        }),
        map(() => props)
      )
    );
  }

  updateAccountMetadata(
    props: UpdateAccountMetadataProps<AccountMetadata>
  ): Promise<UpdateAccountMetadataProps<AccountMetadata>> {
    const { walletId, accountIndex, metadata } = props;
    this.#logger.debug('updateAccountMetadata', walletId, accountIndex, metadata);
    return firstValueFrom(
      this.#getWallets().pipe(
        switchMap((wallets) => {
          // update account
          const bip32Account = findAccount(wallets, walletId, accountIndex);
          if (!bip32Account) {
            throw new WalletConflictError(`Account not found: ${walletId}/${accountIndex}`);
          }
          return this.#store.setAll(
            cloneSplice(wallets, bip32Account.walletIdx, 1, {
              ...bip32Account.wallet,
              accounts: cloneSplice(bip32Account.wallet.accounts, bip32Account.accountIdx, 1, {
                ...bip32Account.account,
                metadata
              })
            })
          );
        }),
        map(() => props)
      )
    );
  }

  removeAccount(props: RemoveAccountProps): Promise<RemoveAccountProps> {
    const { walletId, accountIndex } = props;
    this.#logger.debug('removeAccount', walletId, accountIndex);
    return firstValueFrom(
      this.#getWallets().pipe(
        switchMap((wallets) => {
          const bip32Account = findAccount(wallets, walletId, accountIndex);
          if (!bip32Account) {
            throw new WalletConflictError(`Account '${walletId}/${accountIndex}' does not exist`);
          }
          const dependentWallet = wallets.find(
            (wallet) =>
              wallet.type === WalletType.Script &&
              wallet.ownSigners.some((signer) => signer.walletId === walletId && signer.accountIndex === accountIndex)
          );
          if (dependentWallet) {
            throw new WalletConflictError(
              `Wallet '${dependentWallet.walletId}' depends on account '${walletId}/${accountIndex}'`
            );
          }
          return this.#store.setAll(
            cloneSplice(wallets, bip32Account.walletIdx, 1, {
              ...bip32Account.wallet,
              accounts: cloneSplice(bip32Account.wallet.accounts, bip32Account.accountIdx, 1)
            })
          );
        }),
        map(() => props)
      )
    );
  }

  removeWallet(walletId: WalletId): Promise<WalletId> {
    this.#logger.debug('removeWallet', walletId);
    return firstValueFrom(
      this.#getWallets().pipe(
        take(1),
        switchMap((wallets) => {
          const walletIndex = wallets.findIndex((w) => w.walletId === walletId);
          if (walletIndex < 0) {
            throw new WalletConflictError(`Wallet '${walletId}' does not exist`);
          }
          const dependentWallet = wallets.find(
            (wallet) =>
              wallet.type === WalletType.Script && wallet.ownSigners.some((signer) => signer.walletId === walletId)
          );
          if (dependentWallet) {
            throw new WalletConflictError(`Wallet '${dependentWallet.walletId}' depends on wallet '${walletId}'`);
          }
          return this.#store.setAll(cloneSplice(wallets, walletIndex, 1));
        }),
        map(() => walletId)
      )
    );
  }

  #validateOwnSigners(
    wallets: AnyWallet<WalletMetadata, AccountMetadata>[],
    ownSigners: ScriptWallet<WalletMetadata>['ownSigners']
  ) {
    for (const ownSigner of ownSigners) {
      if (
        !wallets.some(
          (wallet) =>
            wallet.walletId === ownSigner.walletId &&
            wallet.type !== WalletType.Script &&
            wallet.accounts.some((account) => account.accountIndex === ownSigner.accountIndex)
        )
      ) {
        throw new WalletConflictError(
          `Wallet or account does not exist: ${ownSigner.walletId}/${ownSigner.accountIndex}`
        );
      }
    }
  }
}
