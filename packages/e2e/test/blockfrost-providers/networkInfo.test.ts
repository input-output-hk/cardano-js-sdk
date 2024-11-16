// cSpell:ignore cardano utxos

import { NetworkInfoProvider } from '@cardano-sdk/core';
import { getEnv, networkInfoProviderFactory, walletVariables } from '../../src';
import { logger } from '@cardano-sdk/util-dev';
import { networkInfoHttpProvider } from '@cardano-sdk/cardano-services-client';
import { toSerializableObject } from '@cardano-sdk/util';

const env = getEnv(['BLOCKFROST_API_KEY', ...walletVariables]);

// LW-11858 to enable this
describe.skip('Web Socket', () => {
  const legacyProvider = networkInfoHttpProvider({ baseUrl: 'http://localhost:4000/', logger });
  const provider = networkInfoHttpProvider({ baseUrl: 'http://localhost:4001/', logger });

  const methods: (keyof NetworkInfoProvider)[] = [
    'eraSummaries',
    'genesisParameters',
    'lovelaceSupply',
    'protocolParameters',
    'stake'
  ];

  test.each(methods)('compare %s', async (method) => {
    const [legacyResponse, response] = await Promise.all([legacyProvider[method](), provider[method]()]);

    expect(toSerializableObject(response)).toEqual(toSerializableObject(legacyResponse));
  });
});

describe('BlockfrostNetworkInfoProvider', () => {
  let factory: Promise<NetworkInfoProvider>;

  beforeAll(() => {
    factory = networkInfoProviderFactory.create(
      'blockfrost',
      {
        baseUrl: 'https://cardano-preprod.blockfrost.io',
        projectId: env.BLOCKFROST_API_KEY
      },
      logger
    );
  });

  test('stake', async () => {
    const provider = await factory;
    const response = await provider.stake();
    expect(typeof response.active).toBe('bigint');
  });

  test('lovelaceSupply', async () => {
    const provider = await factory;
    const response = await provider.lovelaceSupply();
    expect(typeof response.total).toBe('bigint');
  });

  test('ledgerTip', async () => {
    const provider = await factory;
    const response = await provider.ledgerTip();
    expect(typeof response.blockNo).toBe('number');
  });

  test('protocolParameters', async () => {
    const provider = await factory;
    const response = await provider.protocolParameters();
    expect(typeof response.protocolVersion.major).toBe('number');
  });

  test('genesisParameters', async () => {
    const provider = await factory;
    const response = await provider.genesisParameters();
    expect(typeof response.networkMagic).toBe('number');
  });

  test('eraSummaries', async () => {
    const provider = await factory;
    const response = await provider.eraSummaries();
    expect(typeof response[0].start.slot).toBe('number');
  });
});
