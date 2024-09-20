import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { clearBlockfrostApi, getBlockfrostApi } from '../../../src/util';

describe('BlockfrostClientFactory', () => {
  describe('getBlockfrostApi', () => {
    beforeEach(() => {
      clearBlockfrostApi();
      delete process.env.BLOCKFROST_API_KEY;
      delete process.env.NETWORK;
    });

    it('gets correctly', () => {
      process.env.BLOCKFROST_API_KEY = 'testing';
      process.env.NETWORK = 'preprod';
      const apiFirst = getBlockfrostApi();
      expect(apiFirst).toBeDefined();
      expect(apiFirst).toBeInstanceOf(BlockFrostAPI);

      // deleting proves that we initialize only once
      delete process.env.BLOCKFROST_API_KEY;
      delete process.env.NETWORK;
      const apiSecond = getBlockfrostApi();
      expect(apiSecond).toBeDefined();
      expect(apiSecond).toBeInstanceOf(BlockFrostAPI);
    });

    it('gets custom backend correctly', () => {
      process.env.BLOCKFROST_CUSTOM_BACKEND_URL = 'http://localhost';
      const apiFirst = getBlockfrostApi();
      expect(apiFirst).toBeDefined();
      expect(apiFirst).toBeInstanceOf(BlockFrostAPI);

      // deleting proves that we initialize only once
      delete process.env.BLOCKFROST_CUSTOM_BACKEND_URL;
      const apiSecond = getBlockfrostApi();
      expect(apiSecond).toBeDefined();
      expect(apiSecond).toBeInstanceOf(BlockFrostAPI);
    });

    it('throws if env vars missing', () => {
      expect(() => getBlockfrostApi()).toThrow(
        new Error('BLOCKFROST_API_KEY or BLOCKFROST_CUSTOM_BACKEND_URL environment variable is required')
      );

      process.env.BLOCKFROST_API_KEY = 'testing';
      expect(() => getBlockfrostApi()).toThrow(new Error('NETWORK environment variable is required'));
    });
  });
});
