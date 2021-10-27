import { AssetId, CslTestUtil } from '@cardano-sdk/util-dev';
import { CSL, coreToCsl, cslToCore } from '../../src';

describe('cslToCore', () => {
  describe('value', () => {
    it('coin only', () => {
      const coins = 100_000n;
      const value = CSL.Value.new(CSL.BigNum.from_str(coins.toString()));
      const quantities = cslToCore.value(value);
      expect(quantities.coins).toEqual(coins);
      expect(quantities.assets).toBeUndefined();
    });
    it('coin with assets', () => {
      const coins = 100_000n;
      const assets = { [AssetId.TSLA]: 100n, [AssetId.PXL]: 200n };
      const value = coreToCsl.value({ assets, coins });
      const quantities = cslToCore.value(value);
      expect(quantities.coins).toEqual(coins);
      expect(quantities.assets).toEqual(assets);
    });
  });

  it('txIn', () => {
    const cslInput = CslTestUtil.createTxInput();
    const address = 'addr_test1vrdkagyspkmt96k6z87rnt9dzzy8mlcex7awjymm8wx434q837u24';
    const txIn = cslToCore.txIn(cslInput, address);
    expect(typeof txIn.index).toBe('number');
    expect(typeof txIn.txId).toBe('string');
    expect(txIn.address).toBe(address);
  });
});
