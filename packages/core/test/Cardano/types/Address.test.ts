import { Cardano } from '../../../src';
import { InvalidStringError } from '@cardano-sdk/util';

// eslint-disable-next-line sonarjs/no-duplicate-string
jest.mock('../../../src/Cardano/util/address', () => {
  const actual = jest.requireActual('../../../src/Cardano/util/address');
  return {
    isAddress: jest.fn().mockImplementation((...args) => actual.isAddress(...args))
  };
});
const addressUtilMock = jest.requireMock('../../../src/Cardano/util/address');

describe('Cardano/types/Address', () => {
  it('Address() accepts a valid mainnet grouped address and is implemented using "isAddress" util', () => {
    expect(() =>
      Cardano.PaymentAddress(
        'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
      )
    ).not.toThrow();
    expect(addressUtilMock.isAddress).toBeCalledWith(
      'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
    );
  });

  it('Address() accepts a valid testnet grouped address', () => {
    expect(() =>
      Cardano.PaymentAddress(
        'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
      )
    ).not.toThrow();
  });

  it('Address() accepts a valid mainnet single address', () => {
    expect(() => Cardano.PaymentAddress('addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093')).not.toThrow();
  });

  it('Address() accepts a valid testnet single address', () => {
    expect(() =>
      Cardano.PaymentAddress('addr_test1vrdkagyspkmt96k6z87rnt9dzzy8mlcex7awjymm8wx434q837u24')
    ).not.toThrow();
  });

  it('Address() accepts a valid Daedalus Byron address', () => {
    expect(() =>
      Cardano.PaymentAddress(
        'DdzFFzCqrht4PWfBGtmrQz4x1GkZHYLVGbK7aaBkjWxujxzz3L5GxCgPiTsks5RjUr3yX9KvwKjNJBt7ZzPCmS3fUQrGeRvo9Y1YBQKQ'
      )
    ).not.toThrow();
  });

  it('Address() accepts a valid Yoroi Byron address', () => {
    expect(() => Cardano.PaymentAddress('Ae2tdPwUPEZKkyZinWnudbNtHQddCyc6bCwLVoQx4GfH1NvwztGRpRkewTe')).not.toThrow();
  });

  it('Address() throws error when stake address', () => {
    expect(() =>
      Cardano.PaymentAddress('stake_test1ur676rnu57m272uvflhm8ahgu8xk980vxg382zye2wpxnjs2dnddx')
    ).toThrowError(InvalidStringError);
  });
});
