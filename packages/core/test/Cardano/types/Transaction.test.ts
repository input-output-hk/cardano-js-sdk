import { Cardano, TxBodyCBOR, TxCBOR } from '../../../src/index.js';
import { Ed25519SignatureHex } from '@cardano-sdk/crypto';
import { HexBlob, InvalidStringError } from '@cardano-sdk/util';
import { babbageTx } from '../../CBOR/testData.js';

describe('Cardano/types/Transaction', () => {
  describe('TransactionId', () => {
    describe('when used as a constructor', () => {
      it('accepts a valid transaction hash hex string', () => {
        expect(() =>
          Cardano.TransactionId('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')
        ).not.toThrow();
      });
    });

    describe('fromHexBlob', () => {
      it('accepts a valid length hex string', () => {
        expect(() =>
          Cardano.TransactionId.fromHexBlob(HexBlob('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'))
        ).not.toThrow();
      });

      it('throws when given an invalid length hex string', () => {
        expect(() => Cardano.TransactionId.fromHexBlob(HexBlob('33018e8293d319e'))).toThrowError(InvalidStringError);
      });
    });

    describe('TransactionId.fromTxBodyCbor', () => {
      it('computes transaction hash', () => {
        const bodyCbor = TxBodyCBOR.fromTxCBOR(TxCBOR.serialize(babbageTx));
        const txId = Cardano.TransactionId.fromTxBodyCbor(bodyCbor);
        expect(typeof txId).toBe('string');
        expect(txId).toHaveLength(64);
        // hex characters only
        expect(Buffer.from(txId, 'hex').toString('hex')).toEqual(txId);
      });
    });
  });

  it('Ed25519Signature() accepts a valid signature hex string', () => {
    expect(() =>
      Ed25519SignatureHex(
        // eslint-disable-next-line max-len
        '709f937c4ce152c81f8406c03279ff5a8556a12a8657e40a578eaaa6223d2e6a2fece39733429e3ec73a6c798561b5c2d47d82224d656b1d964cfe8b5fdffe09'
      )
    ).not.toThrow();
  });
});
