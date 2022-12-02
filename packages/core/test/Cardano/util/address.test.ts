import * as parseCmlAddress from '../../../src/CML/parseCmlAddress';
import { Cardano } from '../../../src';

describe('Cardano.util.address', () => {
  const parseCmlAddressSpy = jest.spyOn(parseCmlAddress, 'parseCmlAddress');
  beforeEach(() => parseCmlAddressSpy.mockReset());
  afterAll(() => parseCmlAddressSpy.mockRestore());

  describe('util', () => {
    const addresses = [
      Cardano.Address(
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
      ),
      Cardano.Address(
        'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
      )
    ];

    describe('isAddress', () => {
      it('returns false if the address is invalid', () => {
        parseCmlAddressSpy.mockReturnValueOnce(null);
        expect(Cardano.util.isAddress('invalid')).toBe(false);
      });
      it('returns true if the address is a valid shelley address', () => {
        expect(
          Cardano.util.isAddress(
            // eslint-disable-next-line max-len
            'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
          )
        ).toBe(true);
      });
      it('returns true if the address is a valid stake address', () => {
        expect(Cardano.util.isAddress('stake1vpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5egfu2p0u')).toBe(true);
      });
      it('returns true if the address is a valid byron address', () => {
        expect(
          Cardano.util.isAddress(
            // eslint-disable-next-line max-len
            '37btjrVyb4KDXBNC4haBVPCrro8AQPHwvCMp3RFhhSVWwfFmZ6wwzSK6JK1hY6wHNmtrpTf1kdbva8TCneM2YsiXT7mrzT21EacHnPpz5YyUdj64na'
          )
        ).toBe(true);
      });
    });

    describe('isAddressWithin', () => {
      beforeAll(() => parseCmlAddressSpy.mockRestore());

      it('returns true if address is within provided addresses', () => {
        const address = addresses[0];
        expect(Cardano.util.isAddressWithin(addresses)({ address })).toBe(true);
      });

      it('returns false if address is not within provided addresses', () => {
        const address = Cardano.Address(
          'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
        );
        expect(Cardano.util.isAddressWithin(addresses)({ address })).toBe(false);
      });
    });

    describe('inputsWithAddresses', () => {
      beforeAll(() => parseCmlAddressSpy.mockRestore());
      const tx = {
        body: {
          inputs: [
            {
              address: addresses[0],
              index: 0,
              txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
            }
          ]
        }
      } as Cardano.HydratedTx;

      it('returns the transaction inputs that contain any of the addresses', () => {
        expect(Cardano.util.inputsWithAddresses(tx, addresses)).toEqual([
          {
            address: addresses[0],
            index: 0,
            txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
          }
        ]);
      });

      it('returns an empty array if none of the addresses are in the transaction inputs', () => {
        expect(Cardano.util.inputsWithAddresses(tx, [addresses[1]])).toEqual([]);
      });
    });
  });
});
