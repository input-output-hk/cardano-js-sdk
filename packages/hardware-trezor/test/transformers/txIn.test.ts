import { contextWithKnownAddresses, contextWithoutKnownAddresses, knownAddressKeyPath, txIn } from '../testData';
import { toTrezorTxIn } from '../../src';

describe('tx-inputs', () => {
  describe('toTrezorTxIn', () => {
    it('maps a simple tx input from an unknown third party address', async () => {
      const trezorTxIn = await toTrezorTxIn(txIn, contextWithoutKnownAddresses);
      expect(trezorTxIn).toEqual({
        path: undefined,
        prev_hash: Buffer.from(txIn.txId).toString('hex'),
        prev_index: txIn.index
      });
    });
    it('maps a simple tx input from a known address', async () => {
      const trezorTxIn = await toTrezorTxIn(txIn, contextWithKnownAddresses);
      expect(trezorTxIn).toEqual({
        path: knownAddressKeyPath,
        prev_hash: Buffer.from(txIn.txId).toString('hex'),
        prev_index: txIn.index
      });
    });
  });
});
