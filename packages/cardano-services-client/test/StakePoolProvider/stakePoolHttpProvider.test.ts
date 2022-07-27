import { INFO, createLogger } from 'bunyan';
import { stakePoolHttpProvider } from '../../src';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const config = {
  baseUrl: 'http://some-hostname:3000/stake-pool',
  logger: createLogger({ level: INFO, name: 'unit tests' })
};

describe('stakePoolHttpProvider', () => {
  let axiosMock: MockAdapter;
  beforeAll(() => {
    axiosMock = new MockAdapter(axios);
  });

  afterEach(() => {
    axiosMock.reset();
  });

  afterAll(() => {
    axiosMock.restore();
  });
  test('queryStakePools doesnt throw', async () => {
    axiosMock.onPost().replyOnce(200, []);
    const provider = stakePoolHttpProvider(config);
    await expect(provider.queryStakePools()).resolves.toEqual([]);
  });

  test('stakePoolStats doesnt throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = stakePoolHttpProvider(config);
    await expect(provider.stakePoolStats()).resolves.toEqual({});
  });
});
