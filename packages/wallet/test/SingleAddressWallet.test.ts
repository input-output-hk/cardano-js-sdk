/* eslint-disable max-len */

// All types should be imported from cardano-serialization-lib-nodejs.
// Importing from cardano-serialization-lib-browser will cause TypeScript errors.
// Do not create objects from direct imports of serialization lib, use @cardano-sdk/cardano-serialization-lib.

import { createSingleAddressWallet, SingleAddressWallet } from '@src/SingleAddressWallet';
import * as KeyManagement from '@src/KeyManagement';
import { Cardano, CardanoProvider } from '@cardano-sdk/core';
import { createInMemoryKeyManager, util } from '@cardano-sdk/in-memory-key-manager';
import CardanoSerializationLib from '@emurgo/cardano-serialization-lib-nodejs';
import { loadCardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { InMemoryUtxoRepository } from '@src/InMemoryUtxoRepository';
import { UtxoRepository } from '@src/UtxoRepository';
import { InputSelector, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { providerStub } from './ProviderStub';

describe('Wallet', () => {
  let CSL: typeof CardanoSerializationLib;
  let inputSelector: InputSelector;
  let keyManager: KeyManagement.KeyManager;
  let provider: CardanoProvider;
  let utxoRepository: UtxoRepository;

  beforeEach(async () => {
    CSL = await loadCardanoSerializationLib();
    keyManager = createInMemoryKeyManager({
      mnemonic: util.generateMnemonic(),
      networkId: Cardano.NetworkId.testnet,
      password: '123'
    });
    provider = providerStub();
    inputSelector = roundRobinRandomImprove(CSL);
    utxoRepository = new InMemoryUtxoRepository(provider, keyManager, inputSelector);
  });

  test('createWallet', async () => {
    const wallet = await createSingleAddressWallet(CSL, provider, keyManager, utxoRepository);
    expect(wallet.address).toBeDefined();
    expect(typeof wallet.initializeTx).toBe('function');
    expect(typeof wallet.signTx).toBe('function');
  });

  describe('wallet behaviour', () => {
    let wallet: SingleAddressWallet;
    const props = {
      outputs: [
        {
          address:
            'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w',
          value: { coins: 11_111_111 }
        }
      ]
    };

    beforeEach(async () => {
      wallet = await createSingleAddressWallet(CSL, provider, keyManager, utxoRepository);
    });

    test('initializeTx', async () => {
      const txInternals = await wallet.initializeTx(props);
      expect(txInternals.body).toBeInstanceOf(CSL.TransactionBody);
      expect(txInternals.hash).toBeInstanceOf(CSL.TransactionHash);
    });

    test('signTx', async () => {
      const { body, hash } = await wallet.initializeTx(props);
      const tx = await wallet.signTx(body, hash);
      await expect(tx.body().outputs().len()).toBe(1);
      await expect(tx.body().inputs().len()).toBeGreaterThan(0);
    });

    test('submitTx', async () => {
      const { body, hash } = await wallet.initializeTx(props);
      const tx = await wallet.signTx(body, hash);
      const result = await wallet.submitTx(tx);
      expect(result).toBe(true);
    });
  });
});
