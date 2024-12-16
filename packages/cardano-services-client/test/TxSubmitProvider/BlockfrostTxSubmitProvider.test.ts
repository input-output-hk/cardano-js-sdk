/* eslint-disable @typescript-eslint/no-explicit-any */
import { BlockfrostClient, BlockfrostTxSubmitProvider } from '../../src';
import { HexBlob } from '@cardano-sdk/util';
import { ProviderError } from '@cardano-sdk/core';
import { logger } from '@cardano-sdk/util-dev';
import { mockResponses } from '../util';

describe('blockfrostTxSubmitProvider', () => {
  let request: jest.Mock;
  let provider: BlockfrostTxSubmitProvider;

  beforeEach(async () => {
    request = jest.fn();
    const client = { request } as unknown as BlockfrostClient;
    provider = new BlockfrostTxSubmitProvider(client, logger);
  });

  describe('submitTx', () => {
    it('wraps error in UnknownTxSubmissionError', async () => {
      mockResponses(request, [['tx/submit', new Error('some error')]]);
      await expect(provider.submitTx({ signedTransaction: HexBlob('abc') })).rejects.toThrowError(ProviderError);
    });
  });
});
