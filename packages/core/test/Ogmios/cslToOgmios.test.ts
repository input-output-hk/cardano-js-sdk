import { CardanoSerializationLib, loadCardanoSerializationLib } from '@cardano-sdk/core';
import { cslToOgmios, ogmiosToCsl } from '../../src/Ogmios';

// TODO: move these to dev-util package
const TSLA_Asset = '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41';
const PXL_Asset = '1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c';

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
      const assets = { [TSLA_Asset]: 100n, [PXL_Asset]: 200n };
      const value = ogmiosToCsl(csl).value({ coins, assets });
      const quantities = cslToOgmios.value(value);
      expect(quantities.coins).toEqual(coins);
      expect(quantities.assets).toEqual(assets);
    });
  });
});
