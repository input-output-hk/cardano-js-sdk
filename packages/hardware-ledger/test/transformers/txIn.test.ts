import { CONTEXT_WITHOUT_KNOWN_ADDRESSES, CONTEXT_WITH_KNOWN_ADDRESSES, txIn } from '../testData.js';
import { CardanoKeyConst, TxInId, util } from '@cardano-sdk/key-management';
import { mapTxIns, toTxIn } from '../../src/transformers/index.js';

describe('txIn', () => {
  const paymentKeyPath = { index: 0, role: 1 };

  describe('mapTxIns', () => {
    it('can map a a set of TxIns', async () => {
      const txIns = mapTxIns([txIn, txIn, txIn], {
        ...CONTEXT_WITH_KNOWN_ADDRESSES,
        txInKeyPathMap: { [TxInId(txIn)]: paymentKeyPath }
      });

      expect(txIns.length).toEqual(3);

      for (const input of txIns) {
        expect(input).toEqual({
          outputIndex: txIn.index,
          path: [
            util.harden(CardanoKeyConst.PURPOSE),
            util.harden(CardanoKeyConst.COIN_TYPE),
            util.harden(CONTEXT_WITH_KNOWN_ADDRESSES.accountIndex),
            paymentKeyPath.role,
            paymentKeyPath.index
          ],
          txHashHex: txIn.txId
        });
      }

      expect.assertions(4);
    });
  });

  describe('toTxIn', () => {
    it('can map a simple txIn from third party address', async () => {
      const ledgerTxIn = toTxIn(txIn, CONTEXT_WITHOUT_KNOWN_ADDRESSES);

      expect(ledgerTxIn).toEqual({
        outputIndex: txIn.index,
        path: null,
        txHashHex: txIn.txId
      });
    });

    it('can map a simple txIn from own address', async () => {
      const ledgerTxIn = toTxIn(txIn, {
        ...CONTEXT_WITH_KNOWN_ADDRESSES,
        txInKeyPathMap: { [TxInId(txIn)]: paymentKeyPath }
      });

      expect(ledgerTxIn).toEqual({
        outputIndex: txIn.index,
        path: [
          util.harden(CardanoKeyConst.PURPOSE),
          util.harden(CardanoKeyConst.COIN_TYPE),
          util.harden(CONTEXT_WITH_KNOWN_ADDRESSES.accountIndex),
          paymentKeyPath.role,
          paymentKeyPath.index
        ],
        txHashHex: txIn.txId
      });
    });
  });
});
