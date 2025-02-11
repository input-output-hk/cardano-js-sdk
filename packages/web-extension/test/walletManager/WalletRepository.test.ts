/* eslint-disable sonarjs/no-duplicate-string */
import { AccountMetadata, WalletMetadata, createAccount } from './util';
import {
  AddWalletProps,
  AnyWallet,
  HardwareWallet,
  UpdateAccountMetadataProps,
  UpdateWalletMetadataProps,
  WalletConflictError,
  WalletId,
  WalletRepository,
  WalletType
} from '../../src';
import { BehaviorSubject, firstValueFrom, of } from 'rxjs';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { KeyPurpose, KeyRole } from '@cardano-sdk/key-management';
import { logger } from '@cardano-sdk/util-dev';
import { storage } from '@cardano-sdk/wallet';
import pick from 'lodash/pick.js';

const storedLedgerWallet: HardwareWallet<WalletMetadata, AccountMetadata> = {
  accounts: [createAccount(0, 0)],
  metadata: { name: 'My Ledger Wallet' },
  type: WalletType.Ledger as const,
  walletId: '13e603103d9f6d5aa0cb445ed0d801a9' // result of getWalletId(createPubKey(0, 0))
};

const createTrezorWalletProps: AddWalletProps<WalletMetadata, AccountMetadata> = {
  accounts: [createAccount(1, 0)],
  metadata: { name: 'My Trezor Wallet' },
  type: WalletType.Trezor as const
};

const createScriptWalletProps = {
  accountIndex: 0,
  metadata: { name: 'Treasury' },
  ownSigners: [
    {
      accountIndex: storedLedgerWallet.accounts[0].accountIndex,
      paymentScriptKeyPath: {
        index: 0,
        role: KeyRole.External
      },
      purpose: KeyPurpose.STANDARD,
      stakingScriptKeyPath: {
        index: 0,
        role: KeyRole.External
      },
      walletId: storedLedgerWallet.walletId
    }
  ],
  paymentScript: {
    __type: Cardano.ScriptType.Native,
    kind: Cardano.NativeScriptKind.RequireTimeBefore,
    slot: 123
  } as Cardano.Script,
  stakingScript: {
    __type: Cardano.ScriptType.Native,
    kind: Cardano.NativeScriptKind.RequireTimeBefore,
    slot: 123
  } as Cardano.Script,
  type: WalletType.Script as const
};

const storedScriptWallet = {
  ...createScriptWalletProps,
  metadata: { name: 'Shared' },
  walletId: Serialization.Script.fromCore(createScriptWalletProps.paymentScript).hash().slice(32)
};

type WalletStore = storage.CollectionStore<AnyWallet<WalletMetadata, AccountMetadata>>;

describe('WalletRepository', () => {
  let repository: WalletRepository<WalletMetadata, AccountMetadata>;
  let store: jest.Mocked<WalletStore>;

  beforeEach(() => {
    store = {
      observeAll: jest.fn() as jest.Mocked<WalletStore>['observeAll'],
      setAll: jest.fn() as jest.Mocked<WalletStore>['setAll']
    } as jest.Mocked<WalletStore>;
    repository = new WalletRepository({ logger, store$: of(store) });

    store.observeAll.mockReturnValue(of([storedLedgerWallet]));
    store.setAll.mockReturnValue(of(void 0));
  });

  describe('wallets$', () => {
    it('is an observable of stored wallets', async () => {
      store.observeAll.mockReturnValueOnce(of([storedLedgerWallet]));
      await expect(firstValueFrom(repository.wallets$)).resolves.toEqual([storedLedgerWallet]);
    });

    it('shares subscription to store', async () => {
      store.observeAll.mockReturnValueOnce(of([]));
      await expect(
        Promise.all([firstValueFrom(repository.wallets$), firstValueFrom(repository.wallets$)])
      ).resolves.toEqual([[], []]);
      expect(store.observeAll).toBeCalledTimes(1);
    });
  });

  describe('addWallet', () => {
    it('stores a new wallet', async () => {
      await repository.addWallet(createTrezorWalletProps);
      expect(store.setAll).toBeCalledWith([
        storedLedgerWallet,
        expect.objectContaining({ ...createTrezorWalletProps, walletId: expect.stringContaining('') })
      ]);
    });

    it('rejects with WalletConflictError when no accounts or extended root public key is specified', async () => {
      await expect(
        repository.addWallet({
          ...pick(storedLedgerWallet, ['metadata', 'type']),
          accounts: []
        })
      ).rejects.toThrowError(WalletConflictError);
      expect(store.setAll).not.toBeCalled();
    });

    it('rejects with WalletConflictError when wallet already exists', async () => {
      await expect(
        repository.addWallet(pick(storedLedgerWallet, ['metadata', 'type', 'accounts']))
      ).rejects.toThrowError(WalletConflictError);
      expect(store.setAll).not.toBeCalled();
    });

    it('rejects with WalletConflictError when ownSigners wallet does not exist', async () => {
      await expect(
        repository.addWallet({
          ...createScriptWalletProps,
          ownSigners: [
            {
              accountIndex: createScriptWalletProps.ownSigners[0].accountIndex,
              paymentScriptKeyPath: {
                index: 0,
                role: KeyRole.External
              },
              purpose: KeyPurpose.STANDARD,
              stakingScriptKeyPath: {
                index: 0,
                role: KeyRole.External
              },
              walletId: 'does not exist' as WalletId
            }
          ]
        })
      ).rejects.toThrowError(WalletConflictError);
    });

    it('rejects with WalletConflictError when ownSigners account does not exist', async () => {
      await expect(
        repository.addWallet({
          ...createScriptWalletProps,
          ownSigners: [
            {
              accountIndex: 999_999_999,
              paymentScriptKeyPath: {
                index: 0,
                role: KeyRole.External
              },
              purpose: KeyPurpose.STANDARD,
              stakingScriptKeyPath: {
                index: 0,
                role: KeyRole.External
              },
              walletId: createScriptWalletProps.ownSigners[0].walletId
            }
          ]
        })
      ).rejects.toThrowError(WalletConflictError);
    });

    it('rejects with WalletConflictError when adding a bip32 wallet with no accounts', async () => {
      await expect(
        repository.addWallet({
          ...createTrezorWalletProps,
          accounts: []
        })
      ).rejects.toThrowError(WalletConflictError);
    });

    it('computes and returns WalletId based on first xpub key for bip32 wallets', async () => {
      await expect(repository.addWallet(createTrezorWalletProps)).resolves.toHaveLength(32);
    });

    it('computes and returns WalletId for script wallets', async () => {
      await expect(repository.addWallet(createScriptWalletProps)).resolves.toHaveLength(32);
    });
  });

  describe('addAccount', () => {
    const accountIndex = storedLedgerWallet.accounts[storedLedgerWallet.accounts.length - 1].accountIndex + 1;
    it('adds account to an existing wallet and returns AccountId that also contains walletId', async () => {
      const accountProps = createAccount(0, accountIndex);
      const props = {
        ...accountProps,
        walletId: storedLedgerWallet.walletId
      };
      await expect(repository.addAccount(props)).resolves.toEqual(props);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedLedgerWallet,
          accounts: [...storedLedgerWallet.accounts, accountProps]
        }
      ]);
    });

    it('allows creating 1852 and 1854 purpose account with the same index', async () => {
      const storeSubject = new BehaviorSubject([storedLedgerWallet]);
      store.observeAll.mockReturnValue(storeSubject.asObservable());

      const standardAccountProps = createAccount(0, accountIndex, KeyPurpose.STANDARD);
      const standardProps = {
        ...standardAccountProps,
        walletId: storedLedgerWallet.walletId
      };
      const walletWithStandardAccount = [
        {
          ...storedLedgerWallet,
          accounts: [...storedLedgerWallet.accounts, standardAccountProps]
        }
      ];

      const multiSigAccountProps = createAccount(0, accountIndex, KeyPurpose.MULTI_SIG);
      const multiSigProps = {
        ...multiSigAccountProps,
        walletId: storedLedgerWallet.walletId
      };

      await expect(repository.addAccount(standardProps)).resolves.toEqual(standardProps);
      expect(store.setAll).toBeCalledWith(walletWithStandardAccount);

      storeSubject.next(walletWithStandardAccount);

      await expect(repository.addAccount(multiSigProps)).resolves.toEqual(multiSigProps);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedLedgerWallet,
          accounts: [...walletWithStandardAccount[0].accounts, multiSigAccountProps]
        }
      ]);
    });

    it('rejects with WalletConflictError when wallet is not found', async () => {
      await expect(
        repository.addAccount({
          ...createAccount(0, 1),
          walletId: 'doesnt exist' as Hash28ByteBase16
        })
      ).rejects.toThrowError(WalletConflictError);
      expect(store.setAll).not.toBeCalled();
    });

    it('rejects with WalletConflictError for script wallets', async () => {
      store.observeAll.mockReturnValueOnce(of([storedScriptWallet]));
      await expect(
        repository.addAccount({
          ...createAccount(0, 1),
          walletId: storedScriptWallet.walletId
        })
      ).rejects.toThrowError(WalletConflictError);
      expect(store.setAll).not.toBeCalled();
    });

    it('rejects with WalletConflictError when account already exists', async () => {
      await expect(
        repository.addAccount({
          ...createAccount(0, storedLedgerWallet.accounts[0].accountIndex),
          walletId: storedLedgerWallet.walletId
        })
      ).rejects.toThrowError(WalletConflictError);
      expect(store.setAll).not.toBeCalled();
    });
  });

  describe('updateMetadata', () => {
    const newMetadata = { name: 'New name' };

    it('updates metadata of an existing ledger wallet', async () => {
      const props: UpdateWalletMetadataProps<WalletMetadata> = {
        metadata: newMetadata,
        walletId: storedLedgerWallet.walletId
      };
      await expect(repository.updateWalletMetadata(props)).resolves.toEqual(props);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedLedgerWallet,
          metadata: newMetadata
        }
      ]);
    });

    it('updates metadata of an existing bip32 account', async () => {
      const props: UpdateAccountMetadataProps<WalletMetadata> = {
        accountIndex: storedLedgerWallet.accounts[0].accountIndex,
        metadata: newMetadata,
        walletId: storedLedgerWallet.walletId
      };
      await expect(repository.updateAccountMetadata(props)).resolves.toEqual(props);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedLedgerWallet,
          accounts: [
            {
              ...storedLedgerWallet.accounts[0],
              metadata: newMetadata
            }
          ]
        }
      ]);
    });

    it('updates metadata of an existing script wallet', async () => {
      store.observeAll.mockReturnValueOnce(of([storedScriptWallet]));
      const props: UpdateWalletMetadataProps<WalletMetadata> = {
        metadata: newMetadata,
        walletId: storedScriptWallet.walletId
      };
      await expect(repository.updateWalletMetadata(props)).resolves.toEqual(props);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedScriptWallet,
          metadata: newMetadata
        }
      ]);
    });

    it('does not update 1852 account metadata when updating 1854 account', async () => {
      const storedAccount = storedLedgerWallet.accounts[0];
      const newAccount = createAccount(0, storedAccount.accountIndex, KeyPurpose.MULTI_SIG);
      const accounts = [storedAccount, newAccount];
      store.observeAll.mockReturnValueOnce(of([{ ...storedLedgerWallet, accounts }]));

      const props: UpdateAccountMetadataProps<WalletMetadata> = {
        accountIndex: newAccount.accountIndex,
        metadata: newMetadata,
        purpose: KeyPurpose.MULTI_SIG,
        walletId: storedLedgerWallet.walletId
      };

      await expect(repository.updateAccountMetadata(props)).resolves.toEqual(props);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedLedgerWallet,
          accounts: [
            storedAccount,
            {
              ...newAccount,
              metadata: newMetadata
            }
          ]
        }
      ]);
    });

    it('rejects with WalletConflictError when a bip32 account or a script wallet with specified id is not found', async () => {
      await expect(
        repository.updateWalletMetadata({
          metadata: newMetadata,
          walletId: 'does not exist' as Hash28ByteBase16
        })
      ).rejects.toThrowError(WalletConflictError);
      await expect(
        repository.updateAccountMetadata({
          accountIndex: 999_999_999,
          metadata: newMetadata,
          walletId: storedScriptWallet.walletId
        })
      ).rejects.toThrowError(WalletConflictError);
      expect(store.setAll).not.toBeCalled();
    });
  });

  describe('removeWallet', () => {
    it('removes wallet with specified id', async () => {
      await expect(repository.removeWallet(storedLedgerWallet.walletId)).resolves.toBe(storedLedgerWallet.walletId);
      expect(store.setAll).toBeCalledWith([]);
    });

    it('rejects with WalletConflictError when wallet is not found', async () => {
      await expect(repository.removeWallet('doesnt exist' as Hash28ByteBase16)).rejects.toThrowError(
        WalletConflictError
      );
      expect(store.setAll).not.toBeCalled();
    });

    it('rejects with WalletConflictError when trying to remove wallet referenced by script wallet', async () => {
      store.observeAll.mockReturnValueOnce(of([storedLedgerWallet, storedScriptWallet]));
      await expect(repository.removeWallet(storedScriptWallet.ownSigners[0].walletId)).rejects.toThrowError(
        WalletConflictError
      );
    });
  });

  describe('removeAccount', () => {
    it('removes account with specified index', async () => {
      const props = {
        accountIndex: storedLedgerWallet.accounts[0].accountIndex,
        walletId: storedLedgerWallet.walletId
      };
      await expect(repository.removeAccount(props)).resolves.toEqual(props);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedLedgerWallet,
          accounts: []
        }
      ]);
    });

    it('does not remove 1852 account when removing 1854 account', async () => {
      const storedAccount = storedLedgerWallet.accounts[0];
      const newAccount = createAccount(0, storedAccount.accountIndex, KeyPurpose.MULTI_SIG);
      const accounts = [storedAccount, newAccount];
      store.observeAll.mockReturnValueOnce(of([{ ...storedLedgerWallet, accounts }]));

      const props = {
        accountIndex: newAccount.accountIndex,
        purpose: KeyPurpose.MULTI_SIG,
        walletId: storedLedgerWallet.walletId
      };
      await expect(repository.removeAccount(props)).resolves.toEqual(props);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedLedgerWallet,
          accounts: [storedAccount]
        }
      ]);
    });

    it('rejects with WalletConflictError when account is not found', async () => {
      await expect(
        repository.removeAccount({ accountIndex: 0, walletId: 'doesnt exist' as Hash28ByteBase16 })
      ).rejects.toThrowError(WalletConflictError);
      await expect(
        repository.removeAccount({ accountIndex: 999_999_999, walletId: storedLedgerWallet.walletId })
      ).rejects.toThrowError(WalletConflictError);
      expect(store.setAll).not.toBeCalled();
    });

    it('rejects with WalletConflictError when trying to remove account referenced by script wallet', async () => {
      store.observeAll.mockReturnValueOnce(of([storedLedgerWallet, storedScriptWallet]));
      await expect(
        repository.removeAccount({
          accountIndex: storedScriptWallet.ownSigners[0].accountIndex,
          walletId: storedLedgerWallet.walletId
        })
      ).rejects.toThrowError(WalletConflictError);
    });
  });
});
