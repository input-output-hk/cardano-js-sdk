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
  it('Address() accepts a valid mainnet grouped address and is implemented using "isAddress" util', () => {
    expect(() =>
      Cardano.Address(
        'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
      )
    ).not.toThrow();
    expect(addressUtilMock.isAddress).toBeCalledWith(
      'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
    );
  });
});
