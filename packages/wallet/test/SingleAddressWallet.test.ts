/* eslint-disable max-len */

import { createSingleAddressWallet, SingleAddressWallet } from '@src/SingleAddressWallet';
import * as KeyManagement from '@src/KeyManagement';
import { loadCardanoSerializationLib, CardanoSerializationLib, Cardano, CardanoProvider } from '@cardano-sdk/core';
import { createInMemoryKeyManager, util } from '@src/KeyManagement';
import { InMemoryUtxoRepository } from '@src/InMemoryUtxoRepository';
import { UtxoRepository } from '@src/UtxoRepository';
import { InputSelector, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { providerStub } from './ProviderStub';

describe('Wallet', () => {
  let csl: CardanoSerializationLib;
  let inputSelector: InputSelector;
  let keyManager: KeyManagement.KeyManager;
  let provider: CardanoProvider;
  let utxoRepository: UtxoRepository;

  beforeEach(async () => {
    csl = await loadCardanoSerializationLib();
    keyManager = createInMemoryKeyManager({
      csl,
      mnemonic: util.generateMnemonic(),
      networkId: Cardano.NetworkId.testnet,
      password: '123'
    });
    provider = providerStub();
    inputSelector = roundRobinRandomImprove(csl);
    utxoRepository = new InMemoryUtxoRepository(csl, provider, keyManager, inputSelector);
  });

  test('createWallet', async () => {
    const wallet = await createSingleAddressWallet(csl, provider, keyManager, utxoRepository);
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
      wallet = await createSingleAddressWallet(csl, provider, keyManager, utxoRepository);
    });

    test('initializeTx', async () => {
      const txInternals = await wallet.initializeTx(props);
      expect(txInternals.body).toBeInstanceOf(csl.TransactionBody);
      expect(txInternals.hash).toBeInstanceOf(csl.TransactionHash);
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
