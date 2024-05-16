import {
  MissingCardanoNodeOption,
  createDnsResolver,
  getOgmiosCardanoNode,
  getOgmiosObservableCardanoNode
} from '../../../src';
import { mockDnsResolverFactory } from './util';

import { OgmiosCardanoNode, OgmiosObservableCardanoNode, OgmiosObservableCardanoNodeProps } from '@cardano-sdk/ogmios';
import { SrvRecord } from 'dns';
import { firstValueFrom } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';
import { types } from 'util';

// Connection retry mechanism will recreate an OgmiosCardanoNode and try to reconnect.
// ogmiosCardanoNodeCallTracker tracks which call it is, to configure initialize() to resolve after 1 failure
let ogmiosCardanoNodeCallTracker: number;
let connectionFailureCount: number; // number of times to fail initialize with connection error before succeeding
let initializeError: Object;

jest.mock('@cardano-sdk/ogmios', () => ({
  ...jest.requireActual('@cardano-sdk/ogmios'),
  OgmiosCardanoNode: jest.fn().mockImplementation(() => {
    ogmiosCardanoNodeCallTracker++;
    return {
      initialize: jest.fn(() =>
        ogmiosCardanoNodeCallTracker > connectionFailureCount ? Promise.resolve(true) : Promise.reject(initializeError)
      ),
      shutdown: jest.fn().mockResolvedValue(true)
    };
  }),
  OgmiosObservableCardanoNode: jest.fn()
}));

const mockOgmiosObservableNode = OgmiosObservableCardanoNode as jest.MockedClass<typeof OgmiosObservableCardanoNode>;
const mockOgmiosCardanoNode = OgmiosCardanoNode as jest.MockedClass<typeof OgmiosCardanoNode>;

jest.mock('dns', () => ({
  promises: {
    resolveSrv: async (serviceName: string): Promise<SrvRecord[]> => {
      if (serviceName === process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC)
        return [{ name: 'localhost', port: 5433, priority: 6, weight: 5 }];
      if (serviceName === process.env.OGMIOS_SRV_SERVICE_NAME)
        return [{ name: 'localhost', port: 1337, priority: 6, weight: 5 }];
      return [];
    }
  }
}));

describe('Ogmios Cardano Node factory utils', () => {
  const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
  const ogmiosUrl = new URL('http://dummy');

  const ogmiosPortDefault = 1337;
  const mockDnsResolver = mockDnsResolverFactory(ogmiosPortDefault);

  beforeEach(() => {
    ogmiosCardanoNodeCallTracker = 0;
    connectionFailureCount = 1;
    initializeError = { name: 'ServerNotReady' };

    mockOgmiosCardanoNode.mockClear();
    mockOgmiosObservableNode.mockClear();
  });

  describe('getOgmiosCardanoNode', () => {
    it('creates an OgmiosCardanoNode using the provided URL', async () => {
      await getOgmiosCardanoNode(dnsResolver, logger, { ogmiosUrl });
      expect(mockOgmiosCardanoNode).toHaveBeenCalledTimes(1);
      expect(mockOgmiosCardanoNode.mock.calls[0][0]).toEqual(expect.objectContaining({ host: 'dummy' }));
    });

    it('dnsResolver takes precedence and is used', async () => {
      const dnsResolverMock = await mockDnsResolver(0);
      await getOgmiosCardanoNode(dnsResolverMock, logger, {
        ogmiosSrvServiceName: 'someName',
        ogmiosUrl
      });

      expect(dnsResolverMock).toHaveBeenCalledTimes(1);
      // expected host and port are defined in the mocked dns resolver
      expect(mockOgmiosCardanoNode.mock.calls[0][0]).toEqual({ host: 'localhost', port: ogmiosPortDefault });
    });

    it('throws MissingCardanoNodeOption if no ogmiosUrl or ogmiosSrvServiceName is provided', async () => {
      await expect(getOgmiosCardanoNode(dnsResolver, logger)).rejects.toThrowError(MissingCardanoNodeOption);
    });

    describe('With discovery', () => {
      let ogmiosCardanoNode: OgmiosCardanoNode;
      let dnsResolverMock: jest.Mock;

      beforeEach(async () => {
        dnsResolverMock = await mockDnsResolver(0);
      });

      it('uses a proxy object', async () => {
        ogmiosCardanoNode = await getOgmiosCardanoNode(dnsResolverMock, logger, {
          ogmiosSrvServiceName: 'someName'
        });
        expect(types.isProxy(ogmiosCardanoNode)).toEqual(true);
      });

      it('retries connection errors', async () => {
        connectionFailureCount = 2;
        ogmiosCardanoNode = await getOgmiosCardanoNode(dnsResolverMock, logger, {
          ogmiosSrvServiceName: 'someName'
        });
        await ogmiosCardanoNode.initialize();
        expect(mockOgmiosCardanoNode).toHaveBeenCalledTimes(3);
      });

      it('rethrows errors', async () => {
        initializeError = 'uhm... error';
        ogmiosCardanoNode = await getOgmiosCardanoNode(dnsResolverMock, logger, {
          ogmiosSrvServiceName: 'someName'
        });
        // Regular `rejects` does not work here. Probably because of the Proxy object.
        let hasError = false;
        try {
          await ogmiosCardanoNode.initialize();
        } catch {
          hasError = true;
        }
        expect(hasError).toBeTruthy();
      });
    });
  });

  describe('getOgmiosObservableCardanoNode', () => {
    it('creates an OgmiosObservableCardanoNode using the provided URL', async () => {
      getOgmiosObservableCardanoNode(dnsResolver, logger, { ogmiosUrl });
      expect(mockOgmiosObservableNode).toHaveBeenCalledTimes(1);
      const { connectionConfig$ }: Pick<OgmiosObservableCardanoNodeProps, 'connectionConfig$'> =
        mockOgmiosObservableNode.mock.calls[0][0];
      expect(await firstValueFrom(connectionConfig$)).toEqual(expect.objectContaining({ host: 'dummy' }));
    });

    it('dnsResolver takes precedence and is used', async () => {
      const dnsResolverMock = await mockDnsResolver(0);
      getOgmiosObservableCardanoNode(dnsResolverMock, logger, {
        ogmiosSrvServiceName: 'someName',
        ogmiosUrl
      });

      expect(mockOgmiosObservableNode).toHaveBeenCalledTimes(1);

      const { connectionConfig$ }: Pick<OgmiosObservableCardanoNodeProps, 'connectionConfig$'> =
        mockOgmiosObservableNode.mock.calls[0][0];

      expect(await firstValueFrom(connectionConfig$)).toEqual({ host: 'localhost', port: ogmiosPortDefault });
      expect(dnsResolverMock).toHaveBeenCalledTimes(1);
    });

    it('throws MissingCardanoNodeOption if no ogmiosUrl or ogmiosSrvServiceName is provided', async () => {
      expect(() => getOgmiosObservableCardanoNode(dnsResolver, logger)).toThrowError(MissingCardanoNodeOption);
    });
  });
});
