import { logger } from '@cardano-sdk/util-dev';
import { setupWallet } from '../src';

jest.mock('../src/services/WalletUtil');
const { createLazyWalletUtil } = jest.requireMock('../src/services/WalletUtil');

describe('setupWallet', () => {
  it('initializes WalletUtil with the wallet that is then used as InputResolver for KeyAgent', async () => {
    const initialize = jest.fn();
    const walletUtil = { initialize };
    createLazyWalletUtil.mockReturnValueOnce(walletUtil);
    // actual values doesn't matter for this test, adding any property to be able to assert toEqual
    const keyAgent = { keyAgent: true };
    const wallet = { wallet: true };

    const createKeyAgent = jest.fn().mockResolvedValueOnce(keyAgent);
    const createWallet = jest.fn().mockResolvedValueOnce(wallet);
    expect(
      await setupWallet({
        createKeyAgent,
        createWallet,
        logger
      })
    ).toEqual({ keyAgent, wallet, walletUtil });
    expect(initialize).toBeCalledWith(wallet);
    expect(createKeyAgent).toBeCalledWith({ inputResolver: walletUtil, logger });
    expect(createWallet).toBeCalledWith(keyAgent);
  });
});
