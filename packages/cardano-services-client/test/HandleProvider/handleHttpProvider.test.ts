import { config } from '../util';
import { handleHttpProvider } from '../../src';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';

describe('handleHttpProvider', () => {
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

  test("resolve handles doesn't throw when called with an empty array of handles", async () => {
    const provider = handleHttpProvider(config);

    axiosMock.onPost().replyOnce(200, []);
    await expect(provider.resolveHandles({ handles: [] })).resolves.toEqual([]);
  });

  test('resolve handles has one more parameter', async () => {
    const provider = handleHttpProvider(config);

    axiosMock.onPost().reply((cfg) => [200, cfg.data]);

    await expect(provider.resolveHandles({ handles: ['test'] })).resolves.toEqual({
      check_handle: true,
      handles: ['test']
    });
  });
});
