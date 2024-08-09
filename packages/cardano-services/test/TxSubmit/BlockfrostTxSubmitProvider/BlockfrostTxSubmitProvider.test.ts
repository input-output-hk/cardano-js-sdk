/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */

import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { BlockfrostTxSubmitProvider } from '../../../src';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { logger } from '@cardano-sdk/util-dev';
jest.mock('@blockfrost/blockfrost-js');

describe('blockfrostTxSubmitProvider', () => {
  const apiKey = 'someapikey';

  describe('healthCheck', () => {
    it('returns ok if the service reports a healthy state', async () => {
      BlockFrostAPI.prototype.health = jest.fn().mockResolvedValue({ is_healthy: true });
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostTxSubmitProvider({ blockfrost, logger });
      expect(await provider.healthCheck()).toEqual({ ok: true });
    });
    it('returns not ok if the service reports an unhealthy state', async () => {
      BlockFrostAPI.prototype.health = jest.fn().mockResolvedValue({ is_healthy: false });
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostTxSubmitProvider({ blockfrost, logger });
      expect(await provider.healthCheck()).toEqual({ ok: false });
    });
    it('throws a typed error if caught during the service interaction', async () => {
      BlockFrostAPI.prototype.health = jest
        .fn()
        .mockRejectedValue(new ProviderError(ProviderFailure.Unknown, new Error('Some error')));
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostTxSubmitProvider({ blockfrost, logger });
      await expect(provider.healthCheck()).rejects.toThrowError(ProviderError);
    });
  });

  describe('submitTx', () => {
    it('wraps error in UnknownTxSubmissionError', async () => {
      const innerError = new Error('some error');
      BlockFrostAPI.prototype.txSubmit = jest.fn().mockRejectedValue(innerError);
      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const provider = new BlockfrostTxSubmitProvider({ blockfrost, logger });
      await expect(provider.submitTx({ signedTransaction: null as any })).rejects.toThrowError(ProviderError);
    });
  });
});
