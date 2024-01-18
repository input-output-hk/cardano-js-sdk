/* eslint-disable sonarjs/no-duplicate-string */
import {
  AddWalletProps,
  HardwareWallet,
  UpdateAccountMetadataProps,
  UpdateWalletMetadataProps,
  WalletConflictError,
  WalletId,
  WalletRepository,
  WalletRepositoryDependencies,
  WalletType
} from '../../src';
import { Bip32PublicKeyHex, Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { firstValueFrom, of } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';
import pick from 'lodash/pick';

type WalletMetadata = { friendlyName: string };
type AccountMetadata = { friendlyName: string };

const storedLedgerWallet: HardwareWallet<WalletMetadata, AccountMetadata> = {
  accounts: [
    {
      accountIndex: 0,
      metadata: { friendlyName: 'Account #0' }
    }
  ],
  extendedAccountPublicKey: Bip32PublicKeyHex(
    'ba4f80dea2632a17c99ae9d8b934abf02643db5426b889fef14709c85e294aa12ac1f1560a893ea7937c5bfbfdeab459b1a396f1174b9c5a673a640d01880c35'
  ),
  metadata: { friendlyName: 'My Ledger Wallet' },
  type: WalletType.Ledger as const,
  walletId: 'bc10b0e8fdff359b389822d98d4def22'
};

const createTrezorWalletProps: AddWalletProps<WalletMetadata, AccountMetadata> = {
  extendedAccountPublicKey: Bip32PublicKeyHex(
    'ca4f80dea2632a17c99ae9d8b934abf02643db5426b889fef14709c85e294aa12ac1f1560a893ea7937c5bfbfdeab459b1a396f1174b9c5a673a640d01880c35'
  ),
  metadata: { friendlyName: 'My Trezor Wallet' },
  type: WalletType.Trezor as const
};

const createScriptWalletProps = {
  metadata: { friendlyName: 'Treasury' },
  ownSigners: [
    {
      accountIndex: storedLedgerWallet.accounts[0].accountIndex,
      walletId: storedLedgerWallet.walletId
    }
  ],
  script: {
    __type: Cardano.ScriptType.Native,
    kind: Cardano.NativeScriptKind.RequireTimeBefore,
    slot: 123
  } as Cardano.Script,
  type: WalletType.Script as const
};

const storedScriptWallet = {
  ...createScriptWalletProps,
  metadata: { friendlyName: 'Shared' },
  walletId: Serialization.Script.fromCore(createScriptWalletProps.script).hash().slice(32)
};

describe('WalletRepository', () => {
  let repository: WalletRepository<WalletMetadata, AccountMetadata>;
  let store: jest.Mocked<WalletRepositoryDependencies<WalletMetadata, AccountMetadata>['store']>;

  beforeEach(() => {
    store = {
      observeAll: jest.fn() as jest.Mocked<
        WalletRepositoryDependencies<WalletMetadata, AccountMetadata>['store']
      >['observeAll'],
      setAll: jest.fn() as jest.Mocked<WalletRepositoryDependencies<WalletMetadata, AccountMetadata>['store']>['setAll']
    } as jest.Mocked<WalletRepositoryDependencies<WalletMetadata, AccountMetadata>['store']>;
    repository = new WalletRepository({ logger, store });

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
        expect.objectContaining({ ...createTrezorWalletProps, accounts: [], walletId: expect.stringContaining('') })
      ]);
    });

    it('rejects with WalletConflictError when wallet already exists', async () => {
      await expect(
        repository.addWallet(pick(storedLedgerWallet, ['metadata', 'type', 'extendedAccountPublicKey']))
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
              walletId: createScriptWalletProps.ownSigners[0].walletId
            }
          ]
        })
      ).rejects.toThrowError(WalletConflictError);
    });

    it('computes and returns WalletId for bip32 wallets', async () => {
      await expect(repository.addWallet(createTrezorWalletProps)).resolves.toHaveLength(32);
    });

    it('computes and returns WalletId for script wallets', async () => {
      await expect(repository.addWallet(createScriptWalletProps)).resolves.toHaveLength(32);
    });
  });

  describe('addAccount', () => {
    it('adds account to an existing wallet and returns AccountId that also contains walletId', async () => {
      const accountProps = {
        accountIndex: storedLedgerWallet.accounts[storedLedgerWallet.accounts.length - 1].accountIndex + 1,
        metadata: { friendlyName: 'Next account' }
      };
      const props = { ...accountProps, walletId: storedLedgerWallet.walletId };
      await expect(repository.addAccount(props)).resolves.toEqual(props);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedLedgerWallet,
          accounts: [...storedLedgerWallet.accounts, accountProps]
        }
      ]);
    });

    it('rejects with WalletConflictError when wallet is not found', async () => {
      await expect(
        repository.addAccount({
          accountIndex: 1,
          metadata: { friendlyName: 'Secret Account' },
          walletId: 'doesnt exist' as Hash28ByteBase16
        })
      ).rejects.toThrowError(WalletConflictError);
      expect(store.setAll).not.toBeCalled();
    });

    it('rejects with WalletConflictError for script wallets', async () => {
      store.observeAll.mockReturnValueOnce(of([storedScriptWallet]));
      await expect(
        repository.addAccount({
          accountIndex: 1,
          metadata: { friendlyName: 'Secret Account' },
          walletId: storedScriptWallet.walletId
        })
      ).rejects.toThrowError(WalletConflictError);
      expect(store.setAll).not.toBeCalled();
    });

    it('rejects with WalletConflictError when account already exists', async () => {
      await expect(
        repository.addAccount({
          accountIndex: storedLedgerWallet.accounts[0].accountIndex,
          metadata: { friendlyName: 'Does not matter' },
          walletId: storedLedgerWallet.walletId
        })
      ).rejects.toThrowError(WalletConflictError);
      expect(store.setAll).not.toBeCalled();
    });
  });

  describe('updateMetadata', () => {
    const newMetadata = { friendlyName: 'New name' };

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
