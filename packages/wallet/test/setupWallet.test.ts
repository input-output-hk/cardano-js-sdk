import * as Crypto from '@cardano-sdk/crypto';
import { logger } from '@cardano-sdk/util-dev';
import { setupWallet } from '../src';

jest.mock('../src/services/WalletUtil');
const { createLazyWalletUtil } = jest.requireMock('../src/services/WalletUtil');

describe('setupWallet', () => {
  const bip32Ed25519 = new Crypto.SodiumBip32Ed25519();

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
        bip32Ed25519,
        createKeyAgent,
        createWallet,
        logger
      })
    ).toEqual({ keyAgent, wallet, walletUtil });
    expect(initialize).toBeCalledWith(wallet);
    expect(createKeyAgent).toBeCalledWith({ bip32Ed25519, inputResolver: walletUtil, logger });
    expect(createWallet).toBeCalledWith(keyAgent);
  });
});
