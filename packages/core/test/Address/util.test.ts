import * as parseCslAddress from '../../src/CSL/parseCslAddress';
import { Address, Cardano } from '../../src';
import { CSL as SerializationLib } from '../../src/CSL';

describe('Address', () => {
  const parseCslAddressSpy = jest.spyOn(parseCslAddress, 'parseCslAddress');
  beforeEach(() => parseCslAddressSpy.mockReset());
  afterAll(() => parseCslAddressSpy.mockRestore());

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
      it('returns false if parseCslAddress returns null', () => {
        parseCslAddressSpy.mockReturnValueOnce(null);
        expect(Address.util.isAddress('invalid')).toBe(false);
      });
      it('returns true if parseCslAddress returns an Address', () => {
        parseCslAddressSpy.mockReturnValueOnce(new SerializationLib.Address());
        expect(Address.util.isAddress('valid')).toBe(true);
      });
    });

    describe('isAddressWithin', () => {
      beforeAll(() => parseCslAddressSpy.mockRestore());

      it('returns true if address is within provided addresses', () => {
        const address = addresses[0];
        expect(Address.util.isAddressWithin(addresses)({ address })).toBe(true);
      });

      it('returns false if address is not within provided addresses', () => {
        const address = Cardano.Address(
          'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
        );
        expect(Address.util.isAddressWithin(addresses)({ address })).toBe(false);
      });
    });

    describe('isOutgoing', () => {
      beforeAll(() => parseCslAddressSpy.mockRestore());
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
      } as Cardano.TxAlonzo;

      it('returns true if any of the addresses are in some of the transaction inputs', () => {
        expect(Address.util.isOutgoing(tx, addresses)).toBe(true);
      });

      it('returns false if none of the addresses are in the transaction inputs', () => {
        expect(Address.util.isOutgoing(tx, [addresses[1]])).toBe(false);
      });
    });
  });
});
