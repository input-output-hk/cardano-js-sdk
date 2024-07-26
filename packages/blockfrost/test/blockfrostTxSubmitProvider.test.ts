/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */

import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { blockfrostTxSubmitProvider } from '../src';
jest.mock('@blockfrost/blockfrost-js');

describe('blockfrostTxSubmitProvider', () => {
  const apiKey = 'someapikey';

  describe('healthCheck', () => {
    it('returns ok if the service reports a healthy state', async () => {
      BlockFrostAPI.prototype.health = jest.fn().mockResolvedValue({ is_healthy: true });
      const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
      const provider = blockfrostTxSubmitProvider(blockfrost);
      expect(await provider.healthCheck()).toEqual({ ok: true });
    });
    it('returns not ok if the service reports an unhealthy state', async () => {
      BlockFrostAPI.prototype.health = jest.fn().mockResolvedValue({ is_healthy: false });
      const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
      const provider = blockfrostTxSubmitProvider(blockfrost);
      expect(await provider.healthCheck()).toEqual({ ok: false });
    });
    it('throws a typed error if caught during the service interaction', async () => {
      BlockFrostAPI.prototype.health = jest
        .fn()
        .mockRejectedValue(new ProviderError(ProviderFailure.Unknown, new Error('Some error')));
      const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
      const provider = blockfrostTxSubmitProvider(blockfrost);
      await expect(provider.healthCheck()).rejects.toThrowError(ProviderError);
    });
  });

  describe('submitTx', () => {
    it('wraps error in UnknownTxSubmissionError', async () => {
      const innerError = new Error('some error');
      BlockFrostAPI.prototype.txSubmit = jest.fn().mockRejectedValue(innerError);
      const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
      const provider = blockfrostTxSubmitProvider(blockfrost);
      await expect(provider.submitTx({ signedTransaction: null as any })).rejects.toThrowError(
        Cardano.UnknownTxSubmissionError
      );
    });
  });
});
