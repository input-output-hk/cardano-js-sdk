/* eslint-disable max-len */
import { CML, parseCmlAddress } from '../../src';
import { ManagedFreeableScope } from '@cardano-sdk/util';

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
    grouped: {
      mainnet:
        'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn',
      testnet:
        'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
    },
    single: {
      mainnet: 'addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093',
      testnet: 'addr_test1vrdkagyspkmt96k6z87rnt9dzzy8mlcex7awjymm8wx434q837u24'
    }
  }
};

describe('parseCmlAddress', () => {
  let scope: ManagedFreeableScope;

  beforeEach(() => {
    scope = new ManagedFreeableScope();
  });

  afterEach(() => {
    scope.dispose();
  });
  it('returns true if the input is a valid Shelley or Byron-era address, on either the mainnet or testnets', async () => {
    expect(parseCmlAddress(scope, addresses.shelley.grouped.testnet)).toBeInstanceOf(CML.Address);
    expect(parseCmlAddress(scope, addresses.shelley.grouped.mainnet)).toBeInstanceOf(CML.Address);
    expect(parseCmlAddress(scope, addresses.shelley.single.testnet)).toBeInstanceOf(CML.Address);
    expect(parseCmlAddress(scope, addresses.shelley.single.mainnet)).toBeInstanceOf(CML.Address);
    expect(parseCmlAddress(scope, addresses.byron.mainnet.daedalus)).toBeInstanceOf(CML.Address);
    expect(parseCmlAddress(scope, addresses.byron.mainnet.icarus)).toBeInstanceOf(CML.Address);
    expect(parseCmlAddress(scope, addresses.byron.testnet.daedalus)).toBeInstanceOf(CML.Address);
    expect(parseCmlAddress(scope, addresses.byron.testnet.icarus)).toBeInstanceOf(CML.Address);
  });
  test('returns false if the input is not a Cardano address', async () => {
    expect(parseCmlAddress(scope, addresses.invalid.short)).toBe(null);
    expect(parseCmlAddress(scope, addresses.invalid.networkMagic)).toBe(null);
  });
});
