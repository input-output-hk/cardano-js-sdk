import { CardanoProvider, Ogmios } from '@cardano-sdk/core';
import { UtxoRepository } from '@src/UtxoRepository';
import { InMemoryUtxoRepository } from '@src/InMemoryUtxoRepository';
import { roundRobinRandomImprove, InputSelector } from '@cardano-sdk/cip2';
import { loadCardanoSerializationLib, CardanoSerializationLib, CSL } from '@cardano-sdk/cardano-serialization-lib';
import { providerStub, delegate, rewards } from './ProviderStub';
import { createInMemoryKeyManager, util } from '@cardano-sdk/in-memory-key-manager';
import { NO_CONSTRAINTS } from './util';

const addresses = [
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
];
// const stakeKeyHash = 'stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d';

// const txIn: OgmiosSchema.TxIn[] = [
//   { txId: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5', index: 0 },
//   { txId: '08fc1f8af3abbc8fc1f8a466e6e754833a08a62a059bf059bf5483a8a66e6e74', index: 0 }
// ];

const outputs = CSL.TransactionOutputs.new();

outputs.add(
  Ogmios.OgmiosToCardanoWasm.txOut({
    address: addresses[0],
    // value: { coins: 4_000_000, assets: { '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740': 20n } }
    value: { coins: 4_000_000 }
  })
);
outputs.add(
  Ogmios.OgmiosToCardanoWasm.txOut({
    address: addresses[0],
    // value: { coins: 2_000_000, assets: { '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740': 20n } }
    value: { coins: 2_000_000 }
  })
);

describe('InMemoryUtxoRepository', () => {
  let utxoRepository: UtxoRepository;
  let provider: CardanoProvider;
  let inputSelector: InputSelector;
  let csl: CardanoSerializationLib;

  beforeEach(async () => {
    provider = providerStub();
    csl = await loadCardanoSerializationLib();
    inputSelector = roundRobinRandomImprove(csl);
    const keyManager = createInMemoryKeyManager({
      csl,
      mnemonic: util.generateMnemonic(),
      networkId: 0,
      password: '123'
    });
    utxoRepository = new InMemoryUtxoRepository(provider, keyManager, inputSelector);
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
