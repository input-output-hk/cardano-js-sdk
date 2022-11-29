/* eslint-disable @typescript-eslint/no-explicit-any */
import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { logger } from '@cardano-sdk/util-dev';

import {
  WalletManagerUi,
  consumeRemoteApi,
  exposeApi,
  keyAgentChannel,
  walletChannel,
  walletManagerChannel
} from '../../src';

const consumeApiMock = { activate: jest.fn(), clearStore: jest.fn(), deactivate: jest.fn(), shutdown: jest.fn() };
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
    beforeEach(async () => {
      await walletUi.activate({ keyAgent: {} as AsyncKeyAgent, observableWalletName });
    });

    it('opens unique key agent channel based on observable wallet name', () => {
      expect(exposeApiMock).toHaveBeenCalledTimes(1);
      expect(exposeApiMock.mock.calls[0][0]).toEqual(
        expect.objectContaining({ baseChannel: keyAgentChannel(observableWalletName) })
      );
    });

    it('forwards call to wallet manager api', () => {
      expect(consumeApiMock.activate).toHaveBeenCalledWith(expect.objectContaining({ observableWalletName }));
    });
  });

  describe('deactivate', () => {
    beforeEach(async () => {
      await walletUi.activate({ keyAgent: {} as AsyncKeyAgent, observableWalletName });
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

  it('clearStore: forwards call to wallet manager api', async () => {
    await walletUi.clearStore(observableWalletName);
    expect(consumeApiMock.clearStore).toHaveBeenCalledWith(observableWalletName);
  });

  it('shutdown: closes all channels', async () => {
    await walletUi.activate({ keyAgent: {} as AsyncKeyAgent, observableWalletName });

    walletUi.shutdown();
    expect(consumeApiMock.shutdown).toHaveBeenCalledTimes(2);
    expect(keyAgentApiMock.shutdown).toHaveBeenCalledTimes(1);
  });
});
