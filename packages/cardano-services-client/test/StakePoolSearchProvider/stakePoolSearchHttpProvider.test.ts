import { stakePoolSearchHttpProvider } from '../../src';
import got from 'got';

const url = 'http://some-hostname:3000';

describe('stakePoolSearchHttpProvider', () => {
  beforeAll(() => {
    jest.mock('got');
  });

  afterAll(() => {
    jest.unmock('got');
  });

  test('queryStakePools doesnt throw', async () => {
    got.post = jest.fn().mockReturnValue({ json: jest.fn().mockResolvedValue([]) });
    const provider = stakePoolSearchHttpProvider(url);
    await expect(provider.queryStakePools([])).resolves.toEqual([]);
  });
});
