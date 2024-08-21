import * as k6Utils from '../src/k6-utils';

describe('K6 utils', () => {
  const k6Env = { TARGET_ENV: 'dev', TARGET_NET: 'mainnet' };

  it('uses custom DUT if configured', () => {
    expect(k6Utils.getDut({ DUT: 'localhost:3000' })).toBe('localhost:3000');
  });

  it('builds the correct domain under test based on TARGET_ENV and TARGET_NET', () => {
    expect(k6Utils.getDut(k6Env)).toBe('dev-mainnet.lw.iog.io');
    expect(k6Utils.getDut({ TARGET_ENV: k6Utils.Environment.live, TARGET_NET: k6Utils.Network.preprod })).toBe(
      'live-preprod.lw.iog.io'
    );
    expect(k6Utils.getDut({ TARGET_ENV: k6Utils.Environment.ops, TARGET_NET: k6Utils.Network.preview })).toBe(
      'ops-preview-1.lw.iog.io'
    );
  });

  describe('Runtime validations', () => {
    it('throws an error if none of TARGET_ENV and TARGET_NETWORK, or DUT are configured', () => {
      expect(() => k6Utils.getDut({})).toThrow();
      expect(() => k6Utils.getDut({ TARGET_ENV: k6Utils.Environment.dev })).toThrow();
      expect(() => k6Utils.getDut({ TARGET_NET: k6Utils.Network.mainnet })).toThrow();
    });

    it('checks options type', () => {
      expect(() => k6Utils.getDut(k6Env, 'invalid' as any)).toThrow();
      expect(() => k6Utils.getDut(k6Env, { unknownProp: 'invalid' } as any)).toThrow();
    });

    it('checks options.environments and options.network to be array', () => {
      expect(() => k6Utils.getDut(k6Env, { environments: 'invalid' as any })).toThrow();
      expect(() => k6Utils.getDut(k6Env, { networks: 'invalid' as any })).toThrow();
    });

    it('checks options.environments and options.network to be valid', () => {
      expect(() => k6Utils.getDut(k6Env, { environments: ['invalid' as k6Utils.Environment] })).toThrow();
      expect(() => k6Utils.getDut(k6Env, { networks: ['invalid' as k6Utils.Network] })).toThrow();
    });

    it('checks TARGET_ENV and TARGET_NET to be from options allowed values', () => {
      expect(() =>
        k6Utils.getDut(
          { TARGET_ENV: 'dev', TARGET_NET: 'mainnet' },
          { environments: [k6Utils.Environment.ops], networks: [k6Utils.Network.mainnet] }
        )
      ).toThrow();

      expect(() =>
        k6Utils.getDut(
          { TARGET_ENV: 'dev', TARGET_NET: 'mainnet' },
          { environments: [k6Utils.Environment.dev], networks: [k6Utils.Network.preprod] }
        )
      ).toThrow();
    });
  });
});
