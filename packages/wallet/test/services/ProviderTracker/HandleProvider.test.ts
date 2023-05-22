/* eslint-disable no-magic-numbers */
/* eslint-disable camelcase */
import { KoraLabsHandleProvider } from '../../../src/services/ProviderTracker';
import { createGenericMockServer, mockProviders as mocks } from '@cardano-sdk/util-dev';
import url from 'url';

const bobHandle = {
  hasDatum: false,
  issuer: 'KoraLabs',
  name: 'bob',
  resolved_addresses: {
    ada: 'addr_test1qzrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuql9tk0g'
  },
  resolvedAt: 'zrljm7nskakjydxlr450ktsj08zuw6aktvgfkmm'
};

const aliceHandle = {
  hasDatum: false,
  issuer: 'KoraLabs',
  name: 'alice',
  resolved_addresses: {
    ada: 'addr_test1qqk4sr4f7vtqzd2w90d5nfu3n59jhhpawyphnek2y7er02nkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuqmcnecd'
  },
  resolvedAt: 'zrljm7nskakjydxlr450ktsj08zuw6aktvgssmm'
};

export const mockServer = createGenericMockServer((handler) => async (req, res) => {
  const result = await handler(req);

  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (result.body) {
    res.statusCode = result.code || 200;
    return res.end(JSON.stringify(result.body));
  }

  const reqUrl = url.parse(req.url!).pathname;

  switch (reqUrl) {
    case '/handles/bob':
    case '/handles/alice': {
      return res.end(JSON.stringify(result.body));
    }
    // No default
  }

  return res.end(JSON.stringify(result.body));
});

describe('HandleProvider', () => {
  it('should resolve a handle', async () => {
    const { serverUrl, closeMock } = await mockServer(async () => ({
      body: bobHandle
    }));
    const provider = new KoraLabsHandleProvider({
      networkInfoProvider: mocks.mockNetworkInfoProvider2(100),
      serverUrl
    });
    const tip = await mocks.mockNetworkInfoProvider2(100).ledgerTip();
    const result = await provider.resolveHandles({ handles: ['bob'] });
    expect(result[0].handle).toEqual('bob');
    expect(result[0].resolvedAddresses.cardano).toEqual(bobHandle.resolved_addresses.ada);
    expect(result[0].hasDatum).toEqual(false);
    expect(result[0].resolvedAt.hash).toEqual(tip.hash);
    expect(result[0].resolvedAt.slot).toEqual(tip.slot);
    await closeMock();
  });

  it('should resolve multiple handles', async () => {
    const { serverUrl, closeMock } = await mockServer(async (req) =>
      req?.url === 'handle/bob' ? { body: bobHandle } : { body: aliceHandle }
    );
    const provider = new KoraLabsHandleProvider({
      networkInfoProvider: mocks.mockNetworkInfoProvider2(100),
      serverUrl
    });
    const result = await provider.resolveHandles({ handles: ['bob', 'alice'] });
    expect(result[0].handle).toEqual('bob');
    expect(result[1].handle).toEqual('alice');
    await closeMock();
  });

  it('should get ok health check', async () => {
    const { serverUrl, closeMock } = await mockServer(async () => ({
      body: { ok: true }
    }));
    const provider = new KoraLabsHandleProvider({
      networkInfoProvider: mocks.mockNetworkInfoProvider2(100),
      serverUrl
    });
    const result = await provider.healthCheck();
    expect(result.ok).toEqual(true);
    await closeMock();
  });

  it('should get not ok health check', async () => {
    const provider = new KoraLabsHandleProvider({
      networkInfoProvider: mocks.mockNetworkInfoProvider2(100),
      serverUrl: ''
    });
    const result = await provider.healthCheck();
    expect(result.ok).toEqual(false);
  });
});
