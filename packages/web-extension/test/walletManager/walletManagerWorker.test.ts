/* eslint-disable @typescript-eslint/no-explicit-any */
import { ObservableWallet } from '@cardano-sdk/wallet';
import { logger } from '@cardano-sdk/util-dev';

import { WalletFactory, WalletManagerWorker, keyAgentChannel } from '../../src';
import { consumeRemoteApi, exposeApi } from '../../src/messaging';
import { firstValueFrom } from 'rxjs';

jest.mock('../../src/messaging', () => {
  const originalModule = jest.requireActual('../../src/messaging');
  return {
    __esModule: true,
    ...originalModule,
    consumeRemoteApi: jest.fn().mockReturnValue({ shutdown: jest.fn() }),
    exposeApi: jest.fn().mockReturnValue({ shutdown: jest.fn() })
  };
});

const expectWalletChannelClosed = () => {
  const hostSubscription = exposeApi({} as any, {} as any);
  expect(hostSubscription.shutdown).toHaveBeenCalled();
};

describe('WalletManagerWorker', () => {
  const observableWalletName = 'dummyWallet';
  let walletManager: WalletManagerWorker;
  let walletFactoryCreate: jest.Mock;
  let mockWallet: ObservableWallet;

  const expectWalletDeactivated = () => {
    const keyAgentSubscription = consumeRemoteApi({} as any, {} as any);
    expect(keyAgentSubscription.shutdown).toHaveBeenCalled();
    expect(mockWallet.shutdown).toHaveBeenCalled();
  };

  beforeEach(() => {
    mockWallet = {
      getName: jest.fn().mockResolvedValue(observableWalletName),
      shutdown: jest.fn()
    } as unknown as ObservableWallet;

    walletFactoryCreate = jest.fn().mockResolvedValue(mockWallet);
    const walletFactory: WalletFactory = { create: walletFactoryCreate };

    walletManager = new WalletManagerWorker(
      { walletName: 'ccvault' },
      {
        logger,
        runtime: { connect: jest.fn(), onConnect: jest.fn() as any },
        storesFactory: {
          create: jest
            .fn()
            .mockReturnValueOnce({ id: `${observableWalletName}-A` })
            .mockReturnValueOnce({ id: `${observableWalletName}-B` })
        },
        walletFactory
      }
    );
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('exposes WalletManagerApi messenger', () => {
    expect(exposeApi).toHaveBeenCalled();
  });

  describe('activate', () => {
    beforeEach(async () => {
      await walletManager.activate({ observableWalletName });
    });

    it('consumes keyAgent messenger associated with the wallet', async () => {
      const consumeRemoteApiMock = consumeRemoteApi as jest.Mock;
      expect(consumeRemoteApiMock.mock.calls[0][0]).toEqual(
        expect.objectContaining({ baseChannel: keyAgentChannel(observableWalletName) })
      );
    });

    it('uses wallet factory to create new wallet', () => {
      expect(walletFactoryCreate).toHaveBeenCalled();
    });

    it('persists the store when activating multiple times', async () => {
      const storesFirstActivation = walletFactoryCreate.mock.calls[0][1].stores;
      await walletManager.deactivate();
      await walletManager.activate({ observableWalletName });
      const storesSecondActivation = walletFactoryCreate.mock.calls[1][1].stores;
      expect(storesFirstActivation).toBe(storesSecondActivation);
    });

    it('recreates the store if it was cleared', async () => {
      const storesFirstActivation = walletFactoryCreate.mock.calls[0][1].stores;
      await walletManager.deactivate();
      await walletManager.clearStore(observableWalletName);
      await walletManager.activate({ observableWalletName });
      const storesSecondActivation = walletFactoryCreate.mock.calls[1][1].stores;
      expect(storesFirstActivation).not.toBe(storesSecondActivation);
    });

    it('sets active wallet to wallet created by factory', async () => {
      const activeWallet = await firstValueFrom(walletManager.activeWallet$);
      expect(activeWallet).toEqual(mockWallet);
    });

    it('does not activate same wallet twice', async () => {
      await walletManager.activate({ observableWalletName });
      expect(walletFactoryCreate).toHaveBeenCalledTimes(1);
    });

    it('deactivates previous wallet when activating a new one', async () => {
      await walletManager.activate({ observableWalletName: 'secondWallet' });
      expectWalletDeactivated();
    });
  });

  it('deactivate shuts down the active wallet and key agent remote api', async () => {
    await walletManager.activate({ observableWalletName });
    await walletManager.deactivate();
    expectWalletDeactivated();
  });

  it('shutdown deactivates wallet, key agent and wallet remote apis', async () => {
    await walletManager.activate({ observableWalletName });
    walletManager.shutdown();
    expectWalletDeactivated();
    expectWalletChannelClosed();
  });
});
