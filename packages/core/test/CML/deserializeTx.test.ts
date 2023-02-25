import { HexBlob, InvalidStringError } from '@cardano-sdk/util';
import { deserializeTx } from '../../src/CML/util';

const txId = '9580dbb57df0e160902a942aa4a03ec0090a44bf7c485b2a8fdb8be67127fbf7';
const txBody =
  // eslint-disable-next-line max-len
  '83a400828258209997ab8b1ccbde633aaf99bea1e01354af0ab0a9e79b4c94ec27504aaa0476ae018258204b20cd1b0052f933bb0e2c0b85327b0b26754c15ca62b1da4c5e67ce2c20c1370001828258390070e5d9e766c3b56015acb46dcf06304ce7c2346b5dff6f2724e394e662cd0789a22c3185e7a6070c051320feb59c7acd9444432ae66ef86f1a000f65688258390070e5d9e766c3b56015acb46dcf06304ce7c2346b5dff6f2724e394e662cd0789a22c3185e7a6070c051320feb59c7acd9444432ae66ef86f1a0016d70d021a00029781031a03a45925a100818258207cace81954e301836404d6ee2075be3c6809949b24f1cb2f823a93da3ce46ff35840bbd61c0164c84e9ad72bc3ce111446f409697e6cff539b834032382acbd9b6086feb6a0726d74eba1d14fa376ea91fd8d8b5f6d632223f3e20da192a8323260df6';

describe('deserializeTx', () => {
  describe('converts input', () => {
    it('Cardano.util.HexBlob', () => {
      const tx = deserializeTx(HexBlob(txBody));
      expect(tx.id).toEqual(txId);
    });

    it('Buffer', () => {
      const tx = deserializeTx(Buffer.from(txBody, 'hex'));
      expect(tx.id).toEqual(txId);
    });

    it('Uint8Array', () => {
      const tx = deserializeTx(Uint8Array.from(Buffer.from(txBody, 'hex')));
      expect(tx.id).toEqual(txId);
    });

    it('string', () => {
      const tx = deserializeTx(txBody);
      expect(tx.id).toEqual(txId);
    });
  });

  describe('throws error', () => {
    it('if input is not an hex string', () => expect(() => deserializeTx('qwerty')).toThrow(InvalidStringError));
    it('if input is not a valid transaction', () =>
      expect(() => deserializeTx('abcdef')).toThrow(
        // eslint-disable-next-line max-len
        "Deserialization failed in Transaction because: Invalid cbor: not the right type, expected `Array' byte received `Map'."
      ));
  });
});
