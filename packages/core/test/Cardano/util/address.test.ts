import * as parseCmlAddress from '../../../src/CML/parseCmlAddress';
import { Address } from '../../../src/Cardano';
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

    describe('from hex-encoded bytes', () => {
      it('can return the bech32 shelley address', () => {
        const expectedBech32Addr =
          // eslint-disable-next-line max-len
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp';
        const hexAddr =
          // eslint-disable-next-line max-len
          '009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc';

        expect(Address(hexAddr)).toEqual(expectedBech32Addr);
      });

      it('can return the base58 byron address', () => {
        const expectedBase58Addr =
          // eslint-disable-next-line max-len
          '37btjrVyb4KDXBNC4haBVPCrro8AQPHwvCMp3RFhhSVWwfFmZ6wwzSK6JK1hY6wHNmtrpTf1kdbva8TCneM2YsiXT7mrzT21EacHnPpz5YyUdj64na';

        const hexAddr =
          // eslint-disable-next-line max-len
          '82d818584983581c7e9ee4a9527dea9091e2d580edd6716888c42f75d96276290f98fe0ba201581e581c0cdf39b531d1ac0963cbd183f63e43d895d16a9c567c95e1056e28bd02451a4170cb17001a53249b67';

        expect(Address(hexAddr)).toEqual(expectedBase58Addr);
      });

      it('throws if address is invalid', () => {
        // Valid address but it is a reward address
        expect(() => Address('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')).toThrowError(
          'Address type can only be used for payment addresses'
        );
        // Does not match any of the supported formats
        expect(() => Address('nonHex$string')).toThrowError(
          'Expected payment address as bech32, base58 or hex-encoded bytes'
        );
        // Hex string but it's not an address
        expect(() => Address('deadbeef')).toThrowError('Invalid payment address');
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
