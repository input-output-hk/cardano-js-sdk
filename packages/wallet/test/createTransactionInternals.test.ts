import { loadCardanoSerializationLib, CardanoSerializationLib, CSL } from '@cardano-sdk/cardano-serialization-lib';
import { createTransactionInternals } from '@src/createTransactionInternals';
import { InputSelector, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { Cardano, CardanoProvider, Ogmios } from '@cardano-sdk/core';
import { providerStub } from './ProviderStub';
import { UtxoRepository } from '@src/UtxoRepository';
import { InMemoryUtxoRepository } from '@src/InMemoryUtxoRepository';
import { createInMemoryKeyManager, util } from '@cardano-sdk/in-memory-key-manager';
import { NO_CONSTRAINTS } from './util';

const address =
  'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g';

const outputs = CSL.TransactionOutputs.new();

outputs.add(
  Ogmios.OgmiosToCardanoWasm.txOut({
    address,
    // value: { coins: 4_000_000, assets: { '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740': 20n } }
    value: { coins: 4_000_000 }
  })
);
outputs.add(
  Ogmios.OgmiosToCardanoWasm.txOut({
    address,
    // value: { coins: 2_000_000, assets: { '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740': 20n } }
    value: { coins: 2_000_000 }
  })
);

describe('createTransactionInternals', () => {
  let csl: CardanoSerializationLib;
  let provider: CardanoProvider;
  let inputSelector: InputSelector;
  let utxoRepository: UtxoRepository;

  beforeEach(async () => {
    csl = await loadCardanoSerializationLib();
    provider = providerStub();
    inputSelector = roundRobinRandomImprove(csl);
    const keyManager = createInMemoryKeyManager({
      csl,
      mnemonic: util.generateMnemonic(),
      networkId: Cardano.NetworkId.testnet,
      password: '123'
    });
    utxoRepository = new InMemoryUtxoRepository(provider, keyManager, inputSelector);
  });

  test('simple transaction', async () => {
    const result = await utxoRepository.selectInputs(outputs, NO_CONSTRAINTS);
    const ledgerTip = await provider.ledgerTip();
    const { body, hash } = await createTransactionInternals(csl, {
      changeAddress: 'addr_test1gz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzerspqgpsqe70et',
      inputSelection: result.selection,
      validityInterval: {
        invalidHereafter: ledgerTip.slot + 3600
      }
    });
    expect(body).toBeInstanceOf(csl.TransactionBody);
    expect(hash).toBeInstanceOf(csl.TransactionHash);
  });
});
