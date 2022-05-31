import { stakePoolHttpProvider } from '../../src';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const url = 'http://some-hostname:3000/stake-pool';

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
    const provider = stakePoolHttpProvider(url);
    await expect(provider.queryStakePools()).resolves.toEqual([]);
  });

  test('stakePoolStats doesnt throw', async () => {
    axiosMock.onPost().replyOnce(200, {});
    const provider = stakePoolHttpProvider(url);
    await expect(provider.stakePoolStats()).resolves.toEqual({});
  });
});
