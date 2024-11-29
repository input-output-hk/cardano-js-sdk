import { BlockfrostClient, BlockfrostError } from '../../src';
import { Response } from 'node-fetch';

describe('BlockfrostClient', () => {
  let client: BlockfrostClient;

  beforeEach(() => {
    client = new BlockfrostClient(
      { baseUrl: 'https://blockfrost', projectId: '' },
      { rateLimiter: { schedule: (task) => task() } }
    );
  });

  describe('request', () => {
    it('resolves when fetch is successful', async () => {
      const responseData = { some: 'data' };
      const fetchResponse = new Response(JSON.stringify(responseData), { status: 200 });
      global.fetch = jest.fn().mockResolvedValue(fetchResponse);

      const response = await client.request('/', { body: '123', method: 'POST' });
      expect(response).toEqual(responseData);
    });

    it('rejects with BlockfrostError when fetch fails', async () => {
      const fetchResponse = new Response('Not found', { status: 404 });
      global.fetch = jest.fn().mockResolvedValue(fetchResponse);

      await expect(client.request('/')).rejects.toThrowError(BlockfrostError);
    });
  });
});
