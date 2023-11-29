import {
  AccountId,
  AddAccountProps,
  AddWalletProps,
  AnyWallet,
  ScriptWallet,
  UpdateMetadataProps,
  WalletId,
  WalletRepositoryApi,
  WalletType
} from './types';
import { Bip32PublicKey, Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Logger } from 'ts-log';
import { Observable, defer, firstValueFrom, map, shareReplay, switchMap } from 'rxjs';
import { Serialization } from '@cardano-sdk/core';
import { WalletConflictError } from '../errors';
import { contextLogger, isNotNil } from '@cardano-sdk/util';
import { storage } from '@cardano-sdk/wallet';

export interface WalletRepositoryDependencies<AccountMetadata extends {}> {
  store: storage.CollectionStore<AnyWallet<AccountMetadata>>;
  logger: Logger;
}

const cloneSplice = <T>(array: T[], start: number, deleteCount: number, ...items: T[]) => [
  ...array.slice(0, start),
  ...items,
  ...array.slice(start + deleteCount)
];

const findAccount = <AccountMetadata extends {}>(wallets: AnyWallet<AccountMetadata>[], accountId: AccountId) =>
  wallets
    .map((wallet, walletIndex) => {
      if (wallet.type === WalletType.Script) return;
      const accountIndex = wallet.accounts.findIndex((a) => a.accountId === accountId);
      if (accountIndex < 0) return;
      const account = wallet.accounts[accountIndex];
      return { account, accountIndex, wallet, walletIndex };
    })
    .find(isNotNil);

export class WalletRepository<AccountMetadata extends {}> implements WalletRepositoryApi<AccountMetadata> {
  readonly #logger: Logger;
  readonly #store: WalletRepositoryDependencies<AccountMetadata>['store'];
  readonly wallets$: Observable<AnyWallet<AccountMetadata>[]>;

  constructor({ logger, store }: WalletRepositoryDependencies<AccountMetadata>) {
    this.#store = store;
    this.#logger = contextLogger(logger, 'WalletRepository');
    this.wallets$ = defer(() => store.observeAll()).pipe(shareReplay(1));
  }

  async addWallet(props: AddWalletProps<AccountMetadata>): Promise<WalletId> {
    this.#logger.debug('addWallet', props.type);
    const walletId =
      props.type === WalletType.Script
        ? Serialization.Script.fromCore(props.script).hash()
        : Hash28ByteBase16(await Bip32PublicKey.fromHex(props.extendedAccountPublicKey).hash());
    return firstValueFrom(
      this.wallets$.pipe(
        switchMap((wallets) => {
          if (wallets.some((wallet) => wallet.walletId === walletId)) {
            throw new WalletConflictError(`Wallet '${walletId}' already exists`);
          }
          if (props.type === WalletType.Script) {
            for (const ownSigner of props.ownSigners) {
              if (
                !wallets.some(
                  (wallet) =>
                    wallet.walletId === ownSigner.walletId &&
                    wallet.type !== WalletType.Script &&
                    wallet.accounts.some((account) => account.accountId === ownSigner.accountId)
                )
              ) {
                throw new WalletConflictError(
                  `Wallet or account does not exist: ${ownSigner.walletId}/${ownSigner.accountId}`
                );
              }
            }
          }
          return this.#store.setAll([
            ...wallets,
            props.type === WalletType.Script ? { ...props, walletId } : { ...props, accounts: [], walletId }
          ]);
        }),
        map(() => walletId)
      )
    );
  }

  addAccount({ walletId, accountIndex, metadata }: AddAccountProps<AccountMetadata>): Promise<AccountId> {
    this.#logger.debug('addAccount', walletId, accountIndex, metadata);
    return firstValueFrom(
      this.wallets$.pipe(
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
          const accountId = `${walletId}-${accountIndex}`;
          return this.#store
            .setAll(
              cloneSplice(wallets, walletIndex, 1, {
                ...wallet,
                accounts: [
                  ...wallet.accounts,
                  {
                    accountId,
                    accountIndex,
                    metadata
                  }
                ]
              })
            )
            .pipe(map(() => accountId));
        })
      )
    );
  }

  updateMetadata<ID extends AccountId | WalletId>({
    target,
    metadata
  }: UpdateMetadataProps<AccountMetadata, ID>): Promise<ID> {
    this.#logger.debug('updateMetadata', target, metadata);
    return firstValueFrom(
      this.wallets$.pipe(
        switchMap((wallets) => {
          const bip32Account = findAccount(wallets, target);
          if (bip32Account) {
            return this.#store.setAll(
              cloneSplice(wallets, bip32Account.walletIndex, 1, {
                ...bip32Account.wallet,
                accounts: cloneSplice(bip32Account.wallet.accounts, bip32Account.accountIndex, 1, {
                  ...bip32Account.account,
                  metadata
                })
              })
            );
          }
          const scriptWalletIndex = wallets.findIndex(
            (wallet) => wallet.walletId === target && wallet.type === WalletType.Script
          );
          if (scriptWalletIndex >= 0) {
            return this.#store.setAll(
              cloneSplice(wallets, scriptWalletIndex, 1, {
                ...(wallets[scriptWalletIndex] as ScriptWallet<AccountMetadata>),
                metadata
              })
            );
          }
          throw new WalletConflictError(`BIP32 AccountId or script WalletId not found: ${target}`);
        }),
        map(() => target)
      )
    );
  }

  removeAccount(accountId: AccountId): Promise<AccountId> {
    this.#logger.debug('removeAccount', accountId);
    return firstValueFrom(
      this.wallets$.pipe(
        switchMap((wallets) => {
          const bip32Account = findAccount(wallets, accountId);
          if (!bip32Account) {
            throw new WalletConflictError(`Account '${accountId}' does not exist`);
          }
          const dependentWallet = wallets.find(
            (wallet) =>
              wallet.type === WalletType.Script && wallet.ownSigners.some((signer) => signer.accountId === accountId)
          );
          if (dependentWallet) {
            throw new WalletConflictError(`Wallet '${dependentWallet.walletId}' depends on account '${accountId}'`);
          }
          return this.#store.setAll(
            cloneSplice(wallets, bip32Account.walletIndex, 1, {
              ...bip32Account.wallet,
              accounts: cloneSplice(bip32Account.wallet.accounts, bip32Account.accountIndex, 1)
            })
          );
        }),
        map(() => accountId)
      )
    );
  }

  removeWallet(walletId: WalletId): Promise<WalletId> {
    this.#logger.debug('removeWallet', walletId);
    return firstValueFrom(
      this.wallets$.pipe(
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
}
