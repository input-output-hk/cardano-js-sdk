/* eslint-disable @typescript-eslint/no-explicit-any */
import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { logger } from '@cardano-sdk/util-dev';

import {
  WalletManagerUi,
  consumeRemoteApi,
  exposeApi,
  getWalletId,
  keyAgentChannel,
  walletChannel,
  walletManagerChannel
} from '../../src';

const consumeApiMock = { activate: jest.fn(), deactivate: jest.fn(), destroy: jest.fn(), shutdown: jest.fn() };
const keyAgentApiMock = { shutdown: jest.fn() };
jest.mock('../../src/messaging', () => {
  const originalModule = jest.requireActual('../../src/messaging');
  return {
    __esModule: true,
    ...originalModule,
    consumeRemoteApi: jest.fn().mockImplementation(() => consumeApiMock),
    exposeApi: jest.fn(() => keyAgentApiMock)
  };
});

describe('WalletManagerUi', () => {
  let walletUi: WalletManagerUi;
  const walletName = 'ccvault';
  const observableWalletName = 'preprod-wallet';
  const exposeApiMock = exposeApi as jest.Mock;
  const consumeRemoteApiMock = consumeRemoteApi as jest.Mock;

  const pubKey = Cardano.Bip32PublicKey(
    // eslint-disable-next-line max-len
    '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'
  );

  const mockKeyAgent = {
    getChainId: async () => Promise.resolve({ networkId: Cardano.NetworkId.Testnet, networkMagic: 888 }),
    getExtendedAccountPublicKey: async () => Promise.resolve(pubKey)
  } as AsyncKeyAgent;

  beforeEach(() => {
    walletUi = new WalletManagerUi(
      { walletName },
      { logger, runtime: { connect: jest.fn(), onConnect: jest.fn() as any } }
    );
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('opens the wallet manager and wallet channels when instantiated', () => {
    expect(walletUi).toBeTruthy();
    expect(consumeRemoteApiMock).toHaveBeenCalledTimes(2);
    expect(consumeRemoteApiMock.mock.calls[0][0]).toEqual(
      expect.objectContaining({ baseChannel: walletManagerChannel(walletName) })
    );
    expect(consumeRemoteApiMock.mock.calls[1][0]).toEqual(
      expect.objectContaining({ baseChannel: walletChannel(walletName) })
    );
  });

  describe('activate', () => {
    let walletId: string;

    beforeEach(async () => {
      walletId = await getWalletId(mockKeyAgent);
      await walletUi.activate({ keyAgent: mockKeyAgent, observableWalletName });
    });

    it('opens unique key agent channel based keyAgent chainId and root public key hash name', () => {
      expect(exposeApiMock).toHaveBeenCalledTimes(1);
      expect(exposeApiMock.mock.calls[0][0]).toEqual(
        expect.objectContaining({ baseChannel: keyAgentChannel(walletId) })
      );
    });

    it('forwards call to wallet manager api', () => {
      expect(consumeApiMock.activate).toHaveBeenCalledWith(expect.objectContaining({ observableWalletName, walletId }));
    });

    it('does not activate same wallet twice', async () => {
      await walletUi.activate({ keyAgent: mockKeyAgent, observableWalletName });
      expect(consumeApiMock.activate).toHaveBeenCalledTimes(1);
    });

    it('deactivates previous keyAgent when activating a new one', async () => {
      const anotherKeyAgent = {
        getChainId: async () =>
          Promise.resolve({ networkId: Cardano.NetworkId.Mainnet, networkMagic: Cardano.NetworkMagics.Mainnet }),
        getExtendedAccountPublicKey: async () => Promise.resolve(pubKey)
      } as AsyncKeyAgent;
      await walletUi.activate({ keyAgent: anotherKeyAgent, observableWalletName: 'mainnet-wallet' });
      expect(keyAgentApiMock.shutdown).toHaveBeenCalledTimes(1);
      expect(exposeApiMock).toHaveBeenCalledTimes(2);
    });

    it('destroy: deactivates keyAgent and forwards call to wallet manager api', async () => {
      await walletUi.destroy();
      expect(keyAgentApiMock.shutdown).toHaveBeenCalledTimes(1);
      expect(consumeApiMock.destroy).toHaveBeenCalledTimes(1);
    });
  });

  describe('deactivate', () => {
    beforeEach(async () => {
      await walletUi.activate({ keyAgent: mockKeyAgent, observableWalletName });
      await walletUi.deactivate();
    });

    it('forwards call to wallet manager api', () => {
      expect(consumeApiMock.deactivate).toHaveBeenCalledTimes(1);
    });

    it('closes unique keyagent channel', () => {
      expect(keyAgentApiMock.shutdown).toHaveBeenCalledTimes(1);
    });

    it('can detect keyagent channel was shutdown and does not call it again', async () => {
      await walletUi.deactivate();
      expect(keyAgentApiMock.shutdown).toHaveBeenCalledTimes(1);
    });
  });

  it('shutdown: closes all channels', async () => {
    await walletUi.activate({ keyAgent: mockKeyAgent, observableWalletName });

    walletUi.shutdown();
    expect(consumeApiMock.shutdown).toHaveBeenCalledTimes(2);
    expect(keyAgentApiMock.shutdown).toHaveBeenCalledTimes(1);
  });
});
