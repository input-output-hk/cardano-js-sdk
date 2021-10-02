import { roundRobinRandomImprove, InputSelector } from '@cardano-sdk/cip2';
import { loadCardanoSerializationLib, CardanoSerializationLib, CSL, CardanoProvider, Ogmios } from '@cardano-sdk/core';
import { providerStub, delegate, rewards } from './ProviderStub';
import { InMemoryUtxoRepository, KeyManagement, UtxoRepository } from '../src';
import { NO_CONSTRAINTS } from './util';

const addresses = [
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
];

describe('InMemoryUtxoRepository', () => {
  let utxoRepository: UtxoRepository;
  let provider: CardanoProvider;
  let inputSelector: InputSelector;
  let csl: CardanoSerializationLib;
  let outputs: CSL.TransactionOutput[];

  beforeEach(async () => {
    provider = providerStub();
    csl = await loadCardanoSerializationLib();
    inputSelector = roundRobinRandomImprove(csl);
    const keyManager = KeyManagement.createInMemoryKeyManager({
      csl,
      mnemonicWords: KeyManagement.util.generateMnemonicWords(),
      networkId: 0,
      password: '123'
    });
    outputs = [
      Ogmios.ogmiosToCsl(csl).txOut({
        address: addresses[0],
        value: { coins: 4_000_000 }
      }),
      Ogmios.ogmiosToCsl(csl).txOut({
        address: addresses[0],
        value: { coins: 2_000_000 }
      })
    ];
    utxoRepository = new InMemoryUtxoRepository(csl, provider, keyManager, inputSelector);
  });

  test('constructed state', async () => {
    await expect(utxoRepository.allUtxos.length).toBe(0);
    await expect(utxoRepository.rewards).toBe(null);
    await expect(utxoRepository.delegation).toBe(null);
  });

  test('sync', async () => {
    await utxoRepository.sync();
    await expect(utxoRepository.allUtxos.length).toBe(3);
    await expect(utxoRepository.rewards).toBe(rewards);
    await expect(utxoRepository.delegation).toBe(delegate);
  });

  describe('selectInputs', () => {
    it('can be called without explicitly syncing', async () => {
      const result = await utxoRepository.selectInputs(outputs, NO_CONSTRAINTS);
      await expect(utxoRepository.allUtxos.length).toBe(3);
      await expect(utxoRepository.rewards).toBe(rewards);
      await expect(utxoRepository.delegation).toBe(delegate);
      await expect(result.selection.inputs.length).toBeGreaterThan(0);
      await expect(result.selection.outputs).toBe(outputs);
      await expect(result.selection.change.length).toBe(2);
    });
  });
});
