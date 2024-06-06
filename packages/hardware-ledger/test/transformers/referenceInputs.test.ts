import { mapReferenceInputs } from '../../src/transformers/index.js';
import { txIn } from '../testData.js';
import type { Cardano } from '@cardano-sdk/core';

describe('referenceInputs', () => {
  describe('mapReferenceTxIns', () => {
    it('return null if given an undefined object as reference inputs', async () => {
      const collateralTxIns: Cardano.TxIn[] | undefined = undefined;
      const txIns = mapReferenceInputs(collateralTxIns);
      expect(txIns).toEqual(null);
    });

    it('can map a a set of reference inputs', async () => {
      const txIns = await mapReferenceInputs([txIn, txIn, txIn]);

      expect(txIns!.length).toEqual(3);

      for (const input of txIns!) {
        expect(input).toEqual({
          outputIndex: 0,
          path: null,
          txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
        });
      }

      expect.assertions(4);
    });
  });
});
