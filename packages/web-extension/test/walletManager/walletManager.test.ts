/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import { AccountMetadata, WalletMetadata, createAccount, createPubKey } from './util';
import {
  AddWalletProps,
  AnyWallet,
  WalletFactory,
  WalletId,
  WalletManager,
  WalletRepository,
  WalletType,
  getWalletId,
  getWalletStoreId
} from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { HexBlob, InvalidArgumentError, isNotNil } from '@cardano-sdk/util';
import { MinimalRuntime } from '../../src/messaging';
import { ObservableWallet, storage } from '@cardano-sdk/wallet';
import { Storage } from 'webextension-polyfill';
import { TimeoutError, filter, firstValueFrom, from, of, skip, timeout } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';
import pick from 'lodash/pick.js';

jest.mock('../../src/messaging', () => {
  const originalModule = jest.requireActual('../../src/messaging');
  return {
    __esModule: true,
    ...originalModule,
    consumeRemoteApi: jest.fn().mockReturnValue({ shutdown: jest.fn() }),
    exposeApi: jest.fn().mockReturnValue({ shutdown: jest.fn() })
  };
});

const createInMemoryStorage = () => {
  const store: Record<string, any> = {};
  return {
    clear: jest.fn(),
    get: async (keyOrKeys) =>
      typeof keyOrKeys === 'object'
        ? Array.isArray(keyOrKeys)
          ? pick(store, keyOrKeys)
          : { ...keyOrKeys, ...store }
        : keyOrKeys
        ? pick(store, keyOrKeys)
        : {},
    remove: jest.fn(async (keyOrKeys) => {
      if (Array.isArray(keyOrKeys)) {
        for (const key of keyOrKeys) {
          delete store[key];
        }
      } else {
        delete store[keyOrKeys];
      }
    }),
    set: async (items) => {
      Object.assign(store, items);
    }
  } as Storage.StorageArea;
};

describe('WalletManager', () => {
  let walletId: WalletId;
  let chainId: Cardano.ChainId;
  let managerStorage: Storage.StorageArea;
  let walletManager: WalletManager<WalletMetadata, AccountMetadata>;
  let walletFactoryCreate: jest.Mock;
  let mockWallet: ObservableWallet;
  const runtime: MinimalRuntime = { connect: jest.fn(), onConnect: jest.fn() as any };

  const walletProps: AddWalletProps<WalletMetadata, AccountMetadata> = {
    accounts: [createAccount(0, 0)],
    encryptedSecrets: {
      keyMaterial: HexBlob('f07e8b397c93a16c06f83c8f0c1a1866477c6090926445fc0cb1201228ace6e9'),
      rootPrivateKeyBytes: HexBlob(
        '3809937b61bd4f180a1e9bd15237e7bc20e36b9037dd95ef60d84f6004758250' +
          'a22e1bfc0d81e9adb7760bcba7f5214416b3e9f27c8d58794a3a7fead2d5b695' +
          '8d515cb54181fb2f5fc3af329e80949c082fb52f7b07e359bd7835a6762148bf'
      )
    },
    metadata: { name: 'test' },
    type: WalletType.InMemory
  };

  const scriptWalletProps = {
    metadata: { name: 'Wallet #1' },
    ownSigners: [],
    script: {
      __type: Cardano.ScriptType.Native,
      keyHash: Crypto.Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
      kind: Cardano.NativeScriptKind.RequireSignature
    } as Cardano.Script,
    type: WalletType.Script
  };

  const createWalletManager = async (params?: { mockStorage?: Storage.StorageArea; destroyTracker?: string[] }) => {
    const signingCoordinatorApi = { shutdown: jest.fn(), signData: jest.fn(), signTransaction: jest.fn() };
    const walletFactory: WalletFactory<WalletMetadata, AccountMetadata> = { create: walletFactoryCreate };
    const walletRepository = new WalletRepository<WalletMetadata, AccountMetadata>({
      logger,
      store$: of(new storage.InMemoryCollectionStore<AnyWallet<WalletMetadata, WalletMetadata>>())
    });

    const id = await walletRepository.addWallet(walletProps);

    for (let i = 1; i < 4; i++) {
      await walletRepository.addAccount({
        accountIndex: i,
        extendedAccountPublicKey: createPubKey(0, i),
        metadata: { name: `Account #${i}` },
        walletId: id
      });
    }

    await walletRepository.addWallet({
      metadata: { name: 'Wallet #1' },
      ownSigners: [],
      paymentScript: {
        __type: Cardano.ScriptType.Native,
        keyHash: Crypto.Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
        kind: Cardano.NativeScriptKind.RequireSignature
      },
      stakingScript: {
        __type: Cardano.ScriptType.Native,
        keyHash: Crypto.Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
        kind: Cardano.NativeScriptKind.RequireSignature
      },
      type: WalletType.Script
    });

    return new WalletManager<WalletMetadata, AccountMetadata>(
      { name: 'lace' },
      {
        logger,
        managerStorage: params?.mockStorage ?? managerStorage,
        runtime,
        signingCoordinatorApi,
        storesFactory: {
          create: async (props) =>
            ({
              destroy: jest.fn().mockReturnValue(
                from(
                  new Promise((resolve) => {
                    params?.destroyTracker?.push(props.name);
                    resolve(null);
                  })
                )
              ),
              id: props.name
            } as unknown as storage.WalletStores)
        },
        walletFactory,
        walletRepository
      }
    );
  };

  beforeEach(async () => {
    mockWallet = {
      shutdown: jest.fn()
    } as unknown as ObservableWallet;

    walletFactoryCreate = jest.fn().mockResolvedValue(mockWallet);
    managerStorage = createInMemoryStorage();
    walletManager = await createWalletManager();
    walletId = await getWalletId(walletProps.accounts[0].extendedAccountPublicKey);
    chainId = Cardano.ChainIds.Preprod;
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('activate', () => {
    beforeEach(async () => {
      walletManager = await createWalletManager();
      await walletManager.activate({ accountIndex: 0, chainId, walletId });
    });

    it('uses wallet factory to create new wallet', () => {
      expect(walletFactoryCreate).toHaveBeenCalled();
    });

    it('persists the store when activating multiple times', async () => {
      const storesFirstActivation = walletFactoryCreate.mock.calls[0][1].stores;
      await walletManager.deactivate();
      await walletManager.activate({ accountIndex: 0, chainId, walletId });
      const storesSecondActivation = walletFactoryCreate.mock.calls[1][1].stores;
      expect(storesFirstActivation).toBe(storesSecondActivation);
    });

    it('destroy all the wallet storages for the given wallet id and network', async () => {
      const destroyedStorages: string[] = [];
      walletManager = await createWalletManager({ destroyTracker: destroyedStorages });

      await walletManager.destroyData(walletId, chainId);

      expect(destroyedStorages).toEqual([
        `${chainId.networkId}-${chainId.networkMagic}-${walletId}`,
        `${chainId.networkId}-${chainId.networkMagic}-${walletId}-1`,
        `${chainId.networkId}-${chainId.networkMagic}-${walletId}-2`,
        `${chainId.networkId}-${chainId.networkMagic}-${walletId}-3`
      ]);

      destroyedStorages.length = 0;
      const newChainId = { networkId: Cardano.NetworkId.Testnet, networkMagic: 999 };
      await walletManager.destroyData(walletId, newChainId);

      expect(destroyedStorages).toEqual([
        `${newChainId.networkId}-${newChainId.networkMagic}-${walletId}`,
        `${newChainId.networkId}-${newChainId.networkMagic}-${walletId}-1`,
        `${newChainId.networkId}-${newChainId.networkMagic}-${walletId}-2`,
        `${newChainId.networkId}-${newChainId.networkMagic}-${walletId}-3`
      ]);

      destroyedStorages.length = 0;
      const scriptWalletId = await getWalletId(scriptWalletProps.script);
      await walletManager.destroyData(scriptWalletId, newChainId);

      expect(destroyedStorages).toEqual([`${newChainId.networkId}-${newChainId.networkMagic}-${scriptWalletId}`]);
    });

    it('can reactivate the wallet even if the store was cleared', async () => {
      await walletManager.deactivate();
      await walletManager.destroyData(walletId, chainId);
      await walletManager.activate({ accountIndex: 0, chainId, walletId });
      expect(walletFactoryCreate).toHaveBeenCalledTimes(2);
    });

    it('throws if you try to destroy an active wallet', async () => {
      await expect(walletManager.destroyData(walletId, chainId)).rejects.toThrowError(InvalidArgumentError);
    });

    it('sets active wallet to wallet created by factory', async () => {
      const activeWallet = await firstValueFrom(walletManager.activeWallet$);
      expect(activeWallet).toEqual({
        observableWallet: mockWallet,
        props: expect.objectContaining({ walletId: expect.stringContaining('') })
      });
    });

    it('does not activate same wallet twice', async () => {
      await walletManager.activate({ accountIndex: 0, chainId, walletId });
      expect(walletFactoryCreate).toHaveBeenCalledTimes(1);
    });

    it('compares the chainId using deepEquals', async () => {
      await walletManager.activate({ accountIndex: 0, chainId: { ...chainId }, walletId });
      expect(walletFactoryCreate).toHaveBeenCalledTimes(1);
    });
  });

  describe('deactivate', () => {
    it('deletes lastActivateProps from storage and emits null from activeWalletId$', async () => {
      walletManager = await createWalletManager();
      await walletManager.activate({ accountIndex: 0, chainId, walletId });
      const activeWalletId = firstValueFrom(walletManager.activeWallet$.pipe(skip(1)));
      await walletManager.deactivate();
      expect(managerStorage.remove).toBeCalledTimes(1);
      await expect(activeWalletId).resolves.toBeNull();
    });
  });

  describe('initialize', () => {
    it('does nothing before wallet is activated for the 1st time', async () => {
      await walletManager.initialize();
      await expect(
        firstValueFrom(walletManager.activeWallet$.pipe(filter(isNotNil)).pipe(timeout({ first: 50 })))
      ).rejects.toThrowError(TimeoutError);

      await expect(
        firstValueFrom(walletManager.activeWalletId$.pipe(filter(isNotNil)).pipe(timeout({ first: 50 })))
      ).rejects.toThrowError(TimeoutError);
    });

    it('activates last activated wallet', async () => {
      await walletManager.activate({ accountIndex: 0, chainId, walletId });
      const recreatedWalletManager = await createWalletManager();
      await recreatedWalletManager.initialize();
      expect(await firstValueFrom(recreatedWalletManager.activeWallet$)).toBeTruthy();
    });

    it('can parse last active wallet properties', async () => {
      await managerStorage.set({
        'lace-active-wallet': {
          accountIndex: 0,
          chainId: { networkId: Cardano.NetworkId.Testnet, networkMagic: 888 },
          provider: { a: 'some_attr' },
          walletId
        }
      });

      await walletManager.initialize();

      const {
        walletId: id,
        chainId: chain,
        accountIndex,
        provider
      } = await firstValueFrom(walletManager.activeWalletId$.pipe(filter(isNotNil)));

      expect(id).toEqual(walletId);
      expect(accountIndex).toEqual(0);
      expect(chain).toEqual({ networkId: Cardano.NetworkId.Testnet, networkMagic: 888 });
      expect(provider).toEqual({ a: 'some_attr' });
    });
  });

  describe('wallet store id', () => {
    it('computes wallet store id for account 0 as [id]-[magic]-[32-chars-len-hash]', async () => {
      const id = getWalletStoreId(walletId, chainId, 0);
      expect(id).toEqual(`${chainId.networkId}-${chainId.networkMagic}-${walletId}`);
    });

    it('computes wallet store id for account > 0 as [id]-[magic]-[32-chars-len-hash]-[account-index]', async () => {
      const id = getWalletStoreId(walletId, chainId, 1);
      expect(id).toEqual(`${chainId.networkId}-${chainId.networkMagic}-${walletId}-1`);
    });

    it('computes wallet store id for account undefined as [id]-[magic]-[32-chars-len-hash]', async () => {
      const id = getWalletStoreId(walletId, chainId);
      expect(id).toEqual(`${chainId.networkId}-${chainId.networkMagic}-${walletId}`);
    });
  });

  describe('switchNetwork', () => {
    it('switches the network but keeps the same wallet id and account index', async () => {
      await walletManager.activate({ accountIndex: 0, chainId, walletId });
      const {
        walletId: id,
        chainId: chain,
        accountIndex
      } = await firstValueFrom(walletManager.activeWalletId$.pipe(filter(isNotNil)));
      const newChainId = { networkId: Cardano.NetworkId.Testnet, networkMagic: 999 };

      expect(id).toEqual(walletId);
      expect(accountIndex).toEqual(0);
      expect(chain).toEqual(chainId);

      await walletManager.switchNetwork(newChainId);

      const {
        walletId: idUpdated,
        chainId: chainUpdated,
        accountIndex: accountIndexUpdated
      } = await firstValueFrom(walletManager.activeWalletId$.pipe(filter(isNotNil)));

      expect(idUpdated).toEqual(walletId);
      expect(accountIndexUpdated).toEqual(0);
      expect(chainUpdated).toEqual(newChainId);
    });
  });
});
