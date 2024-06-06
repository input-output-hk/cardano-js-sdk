import { SmashStakePoolDelistedServiceError } from '../../../src/index.js';
import { createSmashStakePoolDelistedService } from '../../../src/StakePool/HttpStakePoolMetadata/SmashStakePoolDelistedService.js';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';
import type { SmashStakePoolDelistedService } from '../../../src/index.js';

describe('StakePoolMetadataService', () => {
  let axiosMock: MockAdapter;
  let service: SmashStakePoolDelistedService;
  const SMASH_URL = 'http://cardano-smash:3100/api/v1';

  beforeAll(() => {
    axiosMock = new MockAdapter(axios);
    service = createSmashStakePoolDelistedService(SMASH_URL, axios);
  });

  afterEach(() => {
    axiosMock.reset();
  });

  afterAll(() => {
    axiosMock.restore();
  });

  describe('getDelistedStakePoolIds', () => {
    const SMASH_DELISTED_URL = `${SMASH_URL}/delisted`;
    const DELISTED_POOLS = [{ poolId: 'pool1' }, { poolId: 'pool2' }, { poolId: 'pool3' }];

    it('get delisted stake pool ids', async () => {
      axiosMock.onGet(SMASH_DELISTED_URL).reply(200, DELISTED_POOLS);

      const result = await service.getDelistedStakePoolIds();

      expect(result).toEqual(DELISTED_POOLS.map((p) => p.poolId));
    });

    it('get empty delisted stake pool ids', async () => {
      axiosMock.onGet(SMASH_DELISTED_URL).reply(200, []);

      const result = await service.getDelistedStakePoolIds();

      expect(result).toEqual([]);
    });

    it('handle non-parsable', async () => {
      axiosMock.onGet(SMASH_DELISTED_URL).reply(200, 'non-parsable response from SMASH');

      const result = await service.getDelistedStakePoolIds();
      const expectedError = new SmashStakePoolDelistedServiceError(
        'TypeError: response.data.map is not a function',
        'SmashStakePoolDelistedService failed to fetch delisted pool ids from http://cardano-smash:3100/api/v1/delisted due to response.data.map is not a function'
      );

      expect(result).toEqual(expectedError);
    });

    it('handle status 500 error', async () => {
      axiosMock.onGet(SMASH_DELISTED_URL).reply(500, []);

      const result = await service.getDelistedStakePoolIds();
      const expectedError = new SmashStakePoolDelistedServiceError(
        'Error: Request failed with status code 500',
        'SmashStakePoolDelistedService failed to fetch delisted pool ids from http://cardano-smash:3100/api/v1/delisted due to Request failed with status code 500'
      );
      expect(result).toEqual(expectedError);
    });

    it('handle status 404 error', async () => {
      axiosMock.onGet(SMASH_DELISTED_URL).reply(404, []);

      const result = await service.getDelistedStakePoolIds();
      const expectedError = new SmashStakePoolDelistedServiceError(
        'Error: Request failed with status code 404',
        'SmashStakePoolDelistedService failed to fetch delisted pool ids from http://cardano-smash:3100/api/v1/delisted due to Request failed with status code 404'
      );
      expect(result).toEqual(expectedError);
    });

    it('handle network error', async () => {
      axiosMock.onGet(SMASH_DELISTED_URL).networkError();

      const result = await service.getDelistedStakePoolIds();
      const expectedError = new SmashStakePoolDelistedServiceError(
        'Error: Network Error',
        'SmashStakePoolDelistedService failed to fetch delisted pool ids from http://cardano-smash:3100/api/v1/delisted due to Network Error'
      );
      expect(result).toEqual(expectedError);
    });

    it('handle timeout', async () => {
      axiosMock.onGet(SMASH_DELISTED_URL).timeout();

      const result = await service.getDelistedStakePoolIds();
      const expectedError = new SmashStakePoolDelistedServiceError(
        'Error: timeout of 0ms exceeded',
        'SmashStakePoolDelistedService failed to fetch delisted pool ids from http://cardano-smash:3100/api/v1/delisted due to timeout of 0ms exceeded'
      );
      expect(result).toEqual(expectedError);
    });
  });
});
