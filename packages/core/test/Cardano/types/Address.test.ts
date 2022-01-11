import { Cardano } from '../../../src';

// eslint-disable-next-line sonarjs/no-duplicate-string
jest.mock('../../../src/Address/util', () => {
  const actual = jest.requireActual('../../../src/Address/util');
  return {
    isAddress: jest.fn().mockImplementation((...args) => actual.isAddress(...args))
  };
});
const addressUtilMock = jest.requireMock('../../../src/Address/util');

describe('Cardano/types/Address', () => {
  it('Address() accepts a valid mainnet grouped address and is implemented using util.typedBech32', () => {
    expect(() =>
      Cardano.Address(
        'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
      )
    ).not.toThrow();
    expect(addressUtilMock.isAddress).toBeCalledWith(
      'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
    );
  });

  it('Address() accepts a valid testnet grouped address', () => {
    expect(() =>
      Cardano.Address(
        'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
      )
    ).not.toThrow();
  });

  it('Address() accepts a valid mainnet single address', () => {
    expect(() => Cardano.Address('addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093')).not.toThrow();
  });

  it('Address() accepts a valid testnet single address', () => {
    expect(() => Cardano.Address('addr_test1vrdkagyspkmt96k6z87rnt9dzzy8mlcex7awjymm8wx434q837u24')).not.toThrow();
  });
});
