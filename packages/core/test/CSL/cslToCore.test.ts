import { AssetId, CslTestUtil } from '@cardano-sdk/util-dev';
import { cslToCore, coreToCsl, CSL } from '../../src';

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
      const value = coreToCsl.value({ coins, assets });
      const quantities = cslToCore.value(value);
      expect(quantities.coins).toEqual(coins);
      expect(quantities.assets).toEqual(assets);
    });
  });

  it('txIn', () => {
    const cslInput = CslTestUtil.createTxInput();
    const txIn = cslToCore.txIn(cslInput);
    expect(typeof txIn.index).toBe('number');
    expect(typeof txIn.txId).toBe('string');
  });
});
