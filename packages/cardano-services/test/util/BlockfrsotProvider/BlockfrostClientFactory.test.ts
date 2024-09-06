import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { clearBlockfrostApi, getBlockfrostApi } from '../../../src/util';

describe('BlockfrostClientFactory', () => {
  describe('getBlockfrostApi', () => {
    beforeEach(() => {
      clearBlockfrostApi();
      delete process.env.BLOCKFROST_API_KEY;
      delete process.env.NETWORK;
    });

    it('gets correctly, first time', () => {
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

    it('throws if env vars missing', () => {
      expect(() => getBlockfrostApi()).toThrow(new Error('BLOCKFROST_API_KEY environment variable is required'));
    });

    it('throws if env vars missing', () => {
      process.env.BLOCKFROST_API_KEY = 'testing';
      expect(() => getBlockfrostApi()).toThrow(new Error('NETWORK environment variable is required'));
    });
  });
});
