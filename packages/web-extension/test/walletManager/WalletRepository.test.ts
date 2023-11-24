/* eslint-disable sonarjs/no-duplicate-string */
import { Bip32PublicKeyHex, Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { WalletConflictError, WalletRepository, WalletRepositoryDependencies, WalletType } from '../../src';
import { firstValueFrom, of } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';
import pick from 'lodash/pick';

type WalletMetadata = { friendlyName: string };

const storedLedgerWallet = {
  accounts: [
    {
      accountId: 'f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80-0',
      accountIndex: 0,
      metadata: { friendlyName: 'My Ledger Wallet' }
    }
  ],
  extendedAccountPublicKey: Bip32PublicKeyHex(
    'ba4f80dea2632a17c99ae9d8b934abf02643db5426b889fef14709c85e294aa12ac1f1560a893ea7937c5bfbfdeab459b1a396f1174b9c5a673a640d01880c35'
  ),
  type: WalletType.Ledger as const,
  walletId: Hash28ByteBase16('ad63f855e831d937457afc52a21a7f351137e4a9fff26c217817335a')
};

const createTrezorWalletProps = {
  extendedAccountPublicKey: Bip32PublicKeyHex(
    'ca4f80dea2632a17c99ae9d8b934abf02643db5426b889fef14709c85e294aa12ac1f1560a893ea7937c5bfbfdeab459b1a396f1174b9c5a673a640d01880c35'
  ),
  type: WalletType.Trezor as const
};

const createScriptWalletProps = {
  metadata: { friendlyName: 'Treasury' },
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
  walletId: Serialization.Script.fromCore(createScriptWalletProps.script).hash()
};

describe('WalletRepository', () => {
  let repository: WalletRepository<WalletMetadata>;
  let store: jest.Mocked<WalletRepositoryDependencies<WalletMetadata>['store']>;

  beforeEach(() => {
    store = {
      observeAll: jest.fn() as jest.Mocked<WalletRepositoryDependencies<WalletMetadata>['store']>['observeAll'],
      setAll: jest.fn() as jest.Mocked<WalletRepositoryDependencies<WalletMetadata>['store']>['setAll']
    } as jest.Mocked<WalletRepositoryDependencies<WalletMetadata>['store']>;
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
        repository.addWallet(pick(storedLedgerWallet, ['type', 'extendedAccountPublicKey']))
      ).rejects.toThrowError(WalletConflictError);
      expect(store.setAll).not.toBeCalled();
    });

    it('computes and returns WalletId for bip32 wallets', async () => {
      await expect(repository.addWallet(createTrezorWalletProps)).resolves.toHaveLength(56);
    });

    it('computes and returns WalletId for script wallets', async () => {
      await expect(repository.addWallet(createScriptWalletProps)).resolves.toHaveLength(56);
    });
  });

  describe('addAccount', () => {
    it('adds account to an existing wallet and returns AccountId that also contains walletId', async () => {
      const accountProps = {
        accountIndex: storedLedgerWallet.accounts[storedLedgerWallet.accounts.length - 1].accountIndex + 1,
        metadata: { friendlyName: 'Next account' }
      };
      await expect(
        repository.addAccount({ ...accountProps, walletId: storedLedgerWallet.walletId })
      ).resolves.toContain(storedLedgerWallet.walletId);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedLedgerWallet,
          accounts: [
            ...storedLedgerWallet.accounts,
            {
              ...accountProps,
              accountId: expect.stringContaining(storedLedgerWallet.walletId)
            }
          ]
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

    it('updates metadata of an existing bip32 account', async () => {
      const accountId = storedLedgerWallet.accounts[0].accountId;
      await expect(
        repository.updateMetadata({
          metadata: newMetadata,
          target: accountId
        })
      ).resolves.toBe(accountId);
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
      await expect(
        repository.updateMetadata({
          metadata: newMetadata,
          target: storedScriptWallet.walletId
        })
      ).resolves.toBe(storedScriptWallet.walletId);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedScriptWallet,
          metadata: newMetadata
        }
      ]);
    });

    it('rejects with WalletConflictError when a bip32 account or a script wallet with specified id is not found', async () => {
      await expect(
        repository.updateMetadata({
          metadata: newMetadata,
          target: 'does not exist'
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
  });

  describe('removeAccount', () => {
    it('removes account with specified id', async () => {
      const accountId = storedLedgerWallet.accounts[0].accountId;
      await expect(repository.removeAccount(accountId)).resolves.toBe(accountId);
      expect(store.setAll).toBeCalledWith([
        {
          ...storedLedgerWallet,
          accounts: []
        }
      ]);
    });

    it('rejects with WalletConflictError when wallet is not found', async () => {
      await expect(repository.removeAccount('doesnt exist' as Hash28ByteBase16)).rejects.toThrowError(
        WalletConflictError
      );
      expect(store.setAll).not.toBeCalled();
    });
  });
});
