// cSpell:ignore cardano utxos

import { NetworkInfoProvider } from '@cardano-sdk/core';
import { logger } from '@cardano-sdk/util-dev';
import { networkInfoHttpProvider } from '@cardano-sdk/cardano-services-client';
import { toSerializableObject } from '@cardano-sdk/util';

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
