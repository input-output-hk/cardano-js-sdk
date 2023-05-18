import { CONTEXT_WITHOUT_KNOWN_ADDRESSES, CONTEXT_WITH_KNOWN_ADDRESSES, txIn } from '../testData';
import { CardanoKeyConst, util } from '@cardano-sdk/key-management';
import { mapTxIns, toTxIn } from '../../src/transformers';

describe('txIn', () => {
  describe('mapTxIns', () => {
    it('can map a a set of TxIns', async () => {
      const txIns = await mapTxIns([txIn, txIn, txIn], CONTEXT_WITH_KNOWN_ADDRESSES);

      expect(txIns.length).toEqual(3);

      for (const input of txIns) {
        expect(input).toEqual({
          outputIndex: 0,
          path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0],
          txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
        });
      }

      expect.assertions(4);
    });
  });

  describe('toTxIn', () => {
    it('can map a simple txIn from third party address', async () => {
      const ledgerTxIn = await toTxIn(txIn, CONTEXT_WITHOUT_KNOWN_ADDRESSES);

      expect(ledgerTxIn).toEqual({
        outputIndex: 0,
        path: null,
        txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
      });
    });

    it('can map a simple txIn from own address', async () => {
      const ledgerTxIn = await toTxIn(txIn, CONTEXT_WITH_KNOWN_ADDRESSES);

      expect(ledgerTxIn).toEqual({
        outputIndex: 0,
        path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0],
        txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
      });
    });
  });
});
