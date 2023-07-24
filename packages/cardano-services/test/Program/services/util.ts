import { getRandomPort } from 'get-port-please';

export const mockDnsResolverFactory = (goodPort: number) => async (numBadResolutions: number, badPort?: number) => {
  let resolverCalledTimes = 0;
  const goodSrvRecord = { name: 'localhost', port: goodPort, priority: 1, weight: 1 };
  badPort ||= await getRandomPort();

  // Initially resolves with a failing ogmios port, then swap to the default one
  return jest.fn().mockImplementation(async () => {
    if (resolverCalledTimes < numBadResolutions) {
      resolverCalledTimes++;
      return { ...goodSrvRecord, port: badPort };
    }
    return goodSrvRecord;
  });
};
