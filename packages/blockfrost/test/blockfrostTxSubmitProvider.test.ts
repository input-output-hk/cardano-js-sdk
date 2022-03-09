/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */

import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { Cardano } from '@cardano-sdk/core';
import { blockfrostTxSubmitProvider } from '../src';
jest.mock('@blockfrost/blockfrost-js');

describe('blockfrostTxSubmitProvider', () => {
  const apiKey = 'someapikey';

  describe('submitTx', () => {
    it('wraps error in UnknownTxSubmissionError', async () => {
      const innerError = new Error('some error');
      BlockFrostAPI.prototype.txSubmit = jest.fn().mockRejectedValue(innerError);
      const provider = blockfrostTxSubmitProvider({ isTestnet: true, projectId: apiKey });
      await expect(provider.submitTx(null as any)).rejects.toThrowError(
        Cardano.TxSubmissionErrors.UnknownTxSubmissionError
      );
    });
  });
});
