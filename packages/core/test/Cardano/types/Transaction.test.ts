import { Ed25519Signature, TransactionId } from '../../../src/Cardano';
import { HexBlob } from '../../../src/Cardano/util';

describe('Cardano/types/Transaction', () => {
  it('TransactionId accepts a valid transaction hash hex string', () => {
    expect(() => TransactionId('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).not.toThrow();
    expect(() =>
      TransactionId.fromHexBlob(HexBlob('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'))
    ).not.toThrow();
  });

  it('Ed25519Signature() accepts a valid signature hex string', () => {
    expect(() =>
      Ed25519Signature(
        // eslint-disable-next-line max-len
        '709f937c4ce152c81f8406c03279ff5a8556a12a8657e40a578eaaa6223d2e6a2fece39733429e3ec73a6c798561b5c2d47d82224d656b1d964cfe8b5fdffe09'
      )
    ).not.toThrow();
  });
});
