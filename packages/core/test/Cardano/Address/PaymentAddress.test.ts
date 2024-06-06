import { Cardano } from '../../../src/index.js';
import { InvalidStringError } from '@cardano-sdk/util';

describe('PaymentAddress', () => {
  const addresses = [
    Cardano.PaymentAddress(
      'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
    ),
    Cardano.PaymentAddress(
      'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
    )
  ];

  it('PaymentAddress() accepts a valid mainnet grouped address', () => {
    expect(() =>
      Cardano.PaymentAddress(
        'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
      )
    ).not.toThrow();
  });

  it('PaymentAddress() accepts a valid testnet grouped address', () => {
    expect(() =>
      Cardano.PaymentAddress(
        'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
      )
    ).not.toThrow();
  });

  it('PaymentAddress() accepts a valid mainnet single address', () => {
    expect(() => Cardano.PaymentAddress('addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093')).not.toThrow();
  });

  it('PaymentAddress() accepts a valid testnet single address', () => {
    expect(() =>
      Cardano.PaymentAddress('addr_test1vrdkagyspkmt96k6z87rnt9dzzy8mlcex7awjymm8wx434q837u24')
    ).not.toThrow();
  });

  it('PaymentAddress() accepts a valid Daedalus Byron address', () => {
    expect(() =>
      Cardano.PaymentAddress(
        'DdzFFzCqrht4PWfBGtmrQz4x1GkZHYLVGbK7aaBkjWxujxzz3L5GxCgPiTsks5RjUr3yX9KvwKjNJBt7ZzPCmS3fUQrGeRvo9Y1YBQKQ'
      )
    ).not.toThrow();
  });

  it('PaymentAddress() accepts a valid Yoroi Byron address', () => {
    expect(() => Cardano.PaymentAddress('Ae2tdPwUPEZKkyZinWnudbNtHQddCyc6bCwLVoQx4GfH1NvwztGRpRkewTe')).not.toThrow();
  });

  it('PaymentAddress() throws error when stake address', () => {
    expect(() =>
      Cardano.PaymentAddress('stake_test1ur676rnu57m272uvflhm8ahgu8xk980vxg382zye2wpxnjs2dnddx')
    ).toThrowError(InvalidStringError);
  });

  it('PaymentAddress() throws an error when passing a DRepID', () => {
    expect(() => Cardano.PaymentAddress('drep1vpzcgfrlgdh4fft0p0ju70czkxxkuknw0jjztl3x7aqgm9q3hqyaz')).toThrowError(
      InvalidStringError
    );
  });

  describe('addressNetworkId', () => {
    it('parses testnet address', () => {
      expect(
        Cardano.addressNetworkId(
          Cardano.PaymentAddress('addr_test1wrsexavz37208qda7mwwu4k7hcpg26cz0ce86f5e9kul3hqzlh22t')
        )
      ).toBe(Cardano.NetworkId.Testnet);
    });

    it('parses testnet reward account', () => {
      expect(
        Cardano.addressNetworkId(
          Cardano.RewardAccount('stake_test1urpklgzqsh9yqz8pkyuxcw9dlszpe5flnxjtl55epla6ftqktdyfz')
        )
      ).toBe(Cardano.NetworkId.Testnet);
    });

    it('parses mainnet address', () => {
      expect(
        Cardano.addressNetworkId(
          Cardano.PaymentAddress(
            'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
          )
        )
      ).toBe(Cardano.NetworkId.Mainnet);
    });

    it('parses mainnet reward account', () => {
      expect(
        Cardano.addressNetworkId(Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'))
      ).toBe(Cardano.NetworkId.Mainnet);
    });

    it('parses mainnet byron address', () => {
      expect(
        Cardano.addressNetworkId(
          Cardano.PaymentAddress(
            'DdzFFzCqrht4PWfBGtmrQz4x1GkZHYLVGbK7aaBkjWxujxzz3L5GxCgPiTsks5RjUr3yX9KvwKjNJBt7ZzPCmS3fUQrGeRvo9Y1YBQKQ'
          )
        )
      ).toBe(Cardano.NetworkId.Mainnet);
    });

    it('parses testnet DRepID', () => {
      expect(
        Cardano.addressNetworkId(Cardano.DRepID('drep1vpzcgfrlgdh4fft0p0ju70czkxxkuknw0jjztl3x7aqgm9q3hqyaz'))
      ).toBe(Cardano.NetworkId.Testnet);
    });

    it('parses mainnet DRepID', () => {
      expect(
        Cardano.addressNetworkId(Cardano.DRepID('drep1v9gkc6jge96t40w46592tahq94n2rzhdhk2puvtz3dsfzys04jeym'))
      ).toBe(Cardano.NetworkId.Mainnet);
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

      expect(Cardano.PaymentAddress(hexAddr)).toEqual(expectedBech32Addr);
    });

    it('can return the base58 byron address', () => {
      const expectedBase58Addr =
        // eslint-disable-next-line max-len
        '37btjrVyb4KDXBNC4haBVPCrro8AQPHwvCMp3RFhhSVWwfFmZ6wwzSK6JK1hY6wHNmtrpTf1kdbva8TCneM2YsiXT7mrzT21EacHnPpz5YyUdj64na';

      const hexAddr =
        // eslint-disable-next-line max-len
        '82d818584983581c7e9ee4a9527dea9091e2d580edd6716888c42f75d96276290f98fe0ba201581e581c0cdf39b531d1ac0963cbd183f63e43d895d16a9c567c95e1056e28bd02451a4170cb17001a53249b67';

      expect(Cardano.PaymentAddress(hexAddr)).toEqual(expectedBase58Addr);
    });

    it('throws if address is invalid', () => {
      // Valid address but it is a reward address
      expect(() =>
        Cardano.PaymentAddress('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
      ).toThrowError('Address type can only be used for payment addresses');
      // Does not match any of the supported formats
      expect(() => Cardano.PaymentAddress('nonHex$string')).toThrowError(
        'Expected payment address as bech32, base58 or hex-encoded bytes'
      );
      // Hex string but it's not an address
      expect(() => Cardano.PaymentAddress('deadbeef')).toThrowError(
        "Invalid argument 'data': Invalid address raw data"
      );
    });
  });

  describe('isAddressWithin', () => {
    it('returns true if address is within provided addresses', () => {
      const address = addresses[0];
      expect(Cardano.isAddressWithin(addresses)({ address })).toBe(true);
    });

    it('returns false if address is not within provided addresses', () => {
      const address = Cardano.PaymentAddress(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      );
      expect(Cardano.isAddressWithin(addresses)({ address })).toBe(false);
    });
  });

  describe('inputsWithAddresses', () => {
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
      expect(Cardano.inputsWithAddresses(tx, addresses)).toEqual([
        {
          address: addresses[0],
          index: 0,
          txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
        }
      ]);
    });

    it('returns an empty array if none of the addresses are in the transaction inputs', () => {
      expect(Cardano.inputsWithAddresses(tx, [addresses[1]])).toEqual([]);
    });
  });
});
