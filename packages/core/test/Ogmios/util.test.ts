import { coalesceValueQuantities, OgmiosValue } from '../../src/Ogmios/util';

describe('Ogmios', () => {
  describe('util', () => {
    describe('coalesceValueQuantities', () => {
      it('coin only', () => {
        const q1: OgmiosValue = { coins: 50n };
        const q2: OgmiosValue = { coins: 100n };
        expect(coalesceValueQuantities([q1, q2])).toEqual({ coins: 150n });
      });
      it('coin and assets', () => {
        const TSLA_Asset = 'b32_1vk0jj9lmv0cjkvmxw337u467atqcgkauwd4eczaugzagyghp25lTSLA';
        const PXL_Asset = 'b32_1rmy9mnhz0ukepmqlng0yee62ve7un05trpzxxg3lnjtqzp4dmmrPXL';
        const q1: OgmiosValue = {
          coins: 50n,
          assets: {
            [TSLA_Asset]: 50n,
            [PXL_Asset]: 100n
          }
        };
        const q2: OgmiosValue = { coins: 100n };
        const q3: OgmiosValue = {
          coins: 20n,
          assets: {
            [TSLA_Asset]: 20n
          }
        };
        expect(coalesceValueQuantities([q1, q2, q3])).toEqual({
          coins: 170n,
          assets: {
            [TSLA_Asset]: 70n,
            [PXL_Asset]: 100n
          }
        });
      });
    });
  });
});
