import * as Crypto from '@cardano-sdk/crypto';
import { AsyncKeyAgent, InMemoryKeyAgent, KeyRole, util } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { dummyLogger } from 'ts-log';

describe('createBip32Ed25519AddressManager', () => {
  let asyncKeyAgent: AsyncKeyAgent;
  let addressManager: util.Bip32Ed25519AddressManager;
  let inputResolver: jest.Mocked<Cardano.InputResolver>;
  const addressDerivationPath = { index: 0, type: 0 };

  beforeEach(async () => {
    const mnemonicWords = util.generateMnemonicWords();
    const getPassphrase = jest.fn().mockResolvedValue(Buffer.from('password'));
    inputResolver = { resolveInput: jest.fn() };
    const keyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        chainId: Cardano.ChainIds.Preview,
        getPassphrase,
        mnemonicWords
      },
      { bip32Ed25519: new Crypto.SodiumBip32Ed25519(), inputResolver, logger: dummyLogger }
    );
    asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
    addressManager = util.createBip32Ed25519AddressManager(asyncKeyAgent);
  });

  it('deriveAddress is unchanged', async () => {
    await expect(asyncKeyAgent.deriveAddress(addressDerivationPath, 0)).resolves.toEqual(
      await addressManager.deriveAddress(addressDerivationPath, 0)
    );
  });

  it('derivePublicKey is unchanged', async () => {
    await expect(asyncKeyAgent.derivePublicKey({ index: 0, role: KeyRole.External })).resolves.toEqual(
      await addressManager.derivePublicKey({ index: 0, role: KeyRole.External })
    );
  });

  it('stops emitting addresses$ after shutdown', (done) => {
    addressManager.shutdown();
    addressManager.knownAddresses$.subscribe({
      complete: done,
      next: () => {
        throw new Error('Should not emit');
      }
    });
    void addressManager.deriveAddress(addressDerivationPath, 0);
  });
});
