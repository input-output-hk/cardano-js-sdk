import { contextWithKnownAddresses, contextWithoutKnownAddresses, knownAddressKeyPath, txIn } from '../testData';
import { mapTxIns, toTrezorTxIn } from '../../src';

const expectedTrezorTxInWithKnownAddress = {
  path: knownAddressKeyPath,
  prev_hash: txIn.txId,
  prev_index: txIn.index
};

const expectedTrezorTxInWithoutKnownAddress = {
  prev_hash: txIn.txId,
  prev_index: txIn.index
};

describe('tx-inputs', () => {
  describe('toTrezorTxIn', () => {
    it('maps a simple tx input from an unknown third party address', async () => {
      const mappedTrezorTxIn = await toTrezorTxIn(txIn, contextWithoutKnownAddresses);
      expect(mappedTrezorTxIn).toEqual(expectedTrezorTxInWithoutKnownAddress);
    });
    it('maps a simple tx input from a known address', async () => {
      const mappedTrezorTxIn = await toTrezorTxIn(txIn, contextWithKnownAddresses);
      expect(mappedTrezorTxIn).toEqual(expectedTrezorTxInWithKnownAddress);
    });
  });
  describe('mapTxIns', () => {
    it('can map a a set of TxIns', async () => {
      const txIns = await mapTxIns([txIn, txIn, txIn], contextWithKnownAddresses);
      expect(txIns).toEqual([
        expectedTrezorTxInWithKnownAddress,
        expectedTrezorTxInWithKnownAddress,
        expectedTrezorTxInWithKnownAddress
      ]);
    });
  });
});
