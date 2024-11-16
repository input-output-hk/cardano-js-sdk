import { UtxoProvider } from '@cardano-sdk/core';
import { getEnv, utxoProviderFactory, walletVariables } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv(['BLOCKFROST_API_KEY', ...walletVariables]);

describe('BlockfrostUtxoProvider', () => {
  let factory: Promise<UtxoProvider>;

  beforeAll(() => {
    if (env.TEST_CLIENT_UTXO_PROVIDER !== 'blockfrost')
      throw new Error('TEST_CLIENT_UTXO_PROVIDER must be "blockfrost" to run these tests');
    factory = utxoProviderFactory.create(
      'blockfrost',
      {
        baseUrl: 'https://cardano-preprod.blockfrost.io',
        projectId: env.BLOCKFROST_API_KEY
      },
      logger
    );
  });

  test('utxoByAddresses', async () => {
    const provider = await factory;
    const lookupAddress =
      'addr_test1qpfgxr33eumjmedu2jvsrn0ac2tzqrtlr40v8gfge4teq5dnmg9jdltvdr8s5u993ajq6zx577yqjl3ugh70ennc4pesqs9289';
    const response = await provider.utxoByAddresses({
      addresses: [lookupAddress]
    });
    expect(response[0][0].address).toBe(lookupAddress);
    expect(typeof response[0][1].value.coins).toBe('bigint');
  });
});
