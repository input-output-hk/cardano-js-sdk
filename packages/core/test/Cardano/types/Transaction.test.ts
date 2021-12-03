import { Ed25519Signature, TransactionId, util } from '../../../src/Cardano';

jest.mock('../../../src/Cardano/util/primitives', () => {
  const actual = jest.requireActual('../../../src/Cardano/util/primitives');
  return {
    Hash32ByteBase16: jest.fn().mockImplementation((...args) => actual.Hash32ByteBase16(...args)),
    typedHex: jest.fn().mockImplementation((...args) => actual.typedHex(...args))
  };
});

describe('Cardano/types/Transaction', () => {
  it('TransactionId accepts a valid transaction hash hex string and is implemented with util.Hash32ByteBase16', () => {
    expect(() => TransactionId('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).not.toThrow();
    expect(util.Hash32ByteBase16).toBeCalledWith('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d');
  });

  it('Ed25519Signature() accepts a valid signature hex string and is implemented using util.typedHex', () => {
    expect(() =>
      Ed25519Signature(
        // eslint-disable-next-line max-len
        '709f937c4ce152c81f8406c03279ff5a8556a12a8657e40a578eaaa6223d2e6a2fece39733429e3ec73a6c798561b5c2d47d82224d656b1d964cfe8b5fdffe09'
      )
    ).not.toThrow();
    expect(util.typedHex).toBeCalledWith(
      // eslint-disable-next-line max-len
      '709f937c4ce152c81f8406c03279ff5a8556a12a8657e40a578eaaa6223d2e6a2fece39733429e3ec73a6c798561b5c2d47d82224d656b1d964cfe8b5fdffe09',
      128
    );
  });
});
