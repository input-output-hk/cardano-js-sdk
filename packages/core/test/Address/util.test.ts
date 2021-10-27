/* eslint-disable max-len */
import { isAddress } from '../../src/Address/util';

export const addresses = {
  byron: {
    mainnet: {
      daedalus:
        'DdzFFzCqrhsw3prhfMFDNFowbzUku3QmrMwarfjUbWXRisodn97R436SHc1rimp4MhPNmbdYb1aTdqtGSJixMVMi5MkArDQJ6Sc1n3Ez',
      icarus: 'Ae2tdPwUPEZFRbyhz3cpfC2CumGzNkFBN2L42rcUc2yjQpEkxDbkPodpMAi'
    },
    testnet: {
      daedalus:
        '37btjrVyb4KEB2STADSsj3MYSAdj52X5FrFWpw2r7Wmj2GDzXjFRsHWuZqrw7zSkwopv8Ci3VWeg6bisU9dgJxW5hb2MZYeduNKbQJrqz3zVBsu9nT',
      icarus: '2cWKMJemoBakkUSWX3DZdx8eXGeqjN6mkgVUCND1RNB736qWS5v1CGgQGNNTFUZSXaVLj'
    }
  },
  invalid: {
    networkMagic:
      '3reY92cShRkjtmz7q31547czPNHbrhbRGhVLehTrNDNDNeDaKJwcM8aMmWg2zd7cHVFvhdui4a86nEdsSEE7g7kcZKKvBw7nzixnbX1',
    short: 'EkxDbkPo'
  },
  shelley: {
    mainnet: 'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn',
    testnet:
      'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
  }
};

describe('Address', () => {
  describe('util', () => {
    describe('isAddress', () => {
      it('returns true if the input is a valid Shelley or Byron-era address, on either the mainnet or testnets', async () => {
        expect(isAddress(addresses.shelley.testnet)).toBe(true);
        expect(isAddress(addresses.shelley.mainnet)).toBe(true);
        expect(isAddress(addresses.byron.mainnet.daedalus)).toBe(true);
        expect(isAddress(addresses.byron.mainnet.icarus)).toBe(true);
        expect(isAddress(addresses.byron.testnet.daedalus)).toBe(true);
        expect(isAddress(addresses.byron.testnet.icarus)).toBe(true);
      });
      test('returns false if the input is not a Cardano address', async () => {
        expect(isAddress(addresses.invalid.short)).toBe(false);
        expect(isAddress(addresses.invalid.networkMagic)).toBe(false);
      });
    });
  });
});
