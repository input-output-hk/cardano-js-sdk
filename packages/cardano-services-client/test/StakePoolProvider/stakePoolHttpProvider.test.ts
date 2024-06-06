import { config } from '../util.js';
import { stakePoolHttpProvider } from '../../src/index.js';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

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
    await expect(provider.queryStakePools({ pagination: { limit: 25, startAt: 1 } })).resolves.toEqual([]);
  });

  test('stakePoolStats doesnt throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = stakePoolHttpProvider(config);
    await expect(provider.stakePoolStats()).resolves.toEqual({});
  });
});
