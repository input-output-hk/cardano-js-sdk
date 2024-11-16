import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import { chainHistoryProviderFactory, getEnv, walletVariables } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv(['BLOCKFROST_API_KEY', ...walletVariables]);

describe('BlockfrostChainHistoryProvider', () => {
  let factory: Promise<ChainHistoryProvider>;

  beforeAll(() => {
    if (env.TEST_CLIENT_CHAIN_HISTORY_PROVIDER !== 'blockfrost')
      throw new Error('TEST_CLIENT_CHAIN_HISTORY_PROVIDER must be "blockfrost" to run these tests');
    factory = chainHistoryProviderFactory.create(
      'blockfrost',
      {
        baseUrl: 'https://cardano-preprod.blockfrost.io',
        projectId: env.BLOCKFROST_API_KEY
      },
      logger
    );
  });

  test('transactionsByAddresses', async () => {
    const provider = await factory;
    const lookupAddress = Cardano.PaymentAddress(
      'addr_test1qpfgxr33eumjmedu2jvsrn0ac2tzqrtlr40v8gfge4teq5dnmg9jdltvdr8s5u993ajq6zx577yqjl3ugh70ennc4pesqs9289'
    );
    const response = await provider.transactionsByAddresses({
      addresses: [lookupAddress],
      pagination: { limit: 2, startAt: 0 }
    });
    expect(typeof response.totalResultCount).toBe('number');
    expect(typeof response.pageResults.length).toBe('number');
    expect(typeof response.pageResults[0].id).toBe('string');
  });

  test('transactionsByAddresses', async () => {
    const provider = await factory;
    const lookupTxId = Cardano.TransactionId('57a84cf1d838b8f36e75c4b8811e6afa975213ba9a551d52449c1f9a31eeeab1');
    const response = await provider.transactionsByHashes({
      ids: [lookupTxId]
    });
    expect(response[0].id).toBe(lookupTxId);
    expect(typeof response[0].txSize).toBe('number');
  });

  test('blocksByAddresses', async () => {
    const provider = await factory;
    const lookupBlockId = Cardano.BlockId('878b644e0ca651ff7be26f2bb7a0d9f789295f256e7f376c9f19a2a3fb8768d6');
    const response = await provider.blocksByHashes({
      ids: [lookupBlockId]
    });
    expect(response[0].header.hash).toBe(lookupBlockId);
    expect(typeof response[0].size).toBe('number');
  });
});
