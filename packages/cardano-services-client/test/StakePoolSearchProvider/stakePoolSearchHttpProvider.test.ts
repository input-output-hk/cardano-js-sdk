import { stakePoolSearchHttpProvider } from '../../src';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

const url = 'http://some-hostname:3000/stake-pool-search';

describe('stakePoolSearchHttpProvider', () => {
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
    const provider = stakePoolSearchHttpProvider(url);
    await expect(provider.queryStakePools()).resolves.toEqual([]);
  });
});
