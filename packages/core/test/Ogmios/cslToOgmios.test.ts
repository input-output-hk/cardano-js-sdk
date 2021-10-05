import { CardanoSerializationLib, loadCardanoSerializationLib } from '@cardano-sdk/core';
import { AssetId } from '@cardano-sdk/util-dev';
import { cslToOgmios, ogmiosToCsl } from '../../src/Ogmios';

describe('util', () => {
  let csl: CardanoSerializationLib;
  beforeAll(async () => {
    csl = await loadCardanoSerializationLib();
  });

  describe('valueToValueQuantities', () => {
    it('coin only', () => {
      const coins = 100_000n;
      const value = csl.Value.new(csl.BigNum.from_str(coins.toString()));
      const quantities = cslToOgmios.value(value);
      expect(quantities.coins).toEqual(coins);
      expect(quantities.assets).toBeUndefined();
    });
    it('coin with assets', () => {
      const coins = 100_000n;
      const assets = { [AssetId.TSLA]: 100n, [AssetId.PXL]: 200n };
      const value = ogmiosToCsl(csl).value({ coins, assets });
      const quantities = cslToOgmios.value(value);
      expect(quantities.coins).toEqual(coins);
      expect(quantities.assets).toEqual(assets);
    });
  });
});
