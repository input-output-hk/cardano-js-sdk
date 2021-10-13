import { cslUtil } from '../../src';

describe('cslUtil', () => {
  describe('bytewiseEquals', () => {
    it('returns true if the two CSL objects have equal byte representation', () => {
      expect(
        cslUtil.bytewiseEquals({ to_bytes: () => new Uint8Array([1, 2]) }, { to_bytes: () => new Uint8Array([1, 2]) })
      ).toBe(true);
    });

    describe('false', () => {
      it('returns false if the two CSL objects have different byte lengths', () => {
        expect(
          cslUtil.bytewiseEquals({ to_bytes: () => new Uint8Array([1, 2]) }, { to_bytes: () => new Uint8Array([1]) })
        ).toBe(false);
      });

      it('returns false if the two CSL objects have different byte representations', () => {
        expect(
          cslUtil.bytewiseEquals({ to_bytes: () => new Uint8Array([1, 2]) }, { to_bytes: () => new Uint8Array([1, 3]) })
        ).toBe(false);
      });
    });
  });
});
