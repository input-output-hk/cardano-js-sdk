/* eslint-disable @typescript-eslint/no-explicit-any */
import * as k6Utils from '../src/k6-utils';
import { Cardano } from '@cardano-sdk/core';
import http from 'k6/http';

describe('K6 utils', () => {
  const localDUT = 'localhost:3000';
  describe('getDut', () => {
    const k6Env = { TARGET_ENV: 'dev', TARGET_NET: 'mainnet' };

    it('uses custom DUT if configured', () => {
      expect(k6Utils.getDut({ DUT: localDUT })).toBe(localDUT);
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

  describe('chunkArray', () => {
    const testArray = [1, 2, 3, 4, 5, 6];
    it('splits an array into chunks of the specified size', () => {
      expect(k6Utils.chunkArray(testArray, 2)).toEqual([
        [1, 2],
        [3, 4],
        [5, 6]
      ]);
      expect(k6Utils.chunkArray(testArray, 3)).toEqual([
        [1, 2, 3],
        [4, 5, 6]
      ]);
      expect(k6Utils.chunkArray(testArray, 6)).toEqual([testArray]);
    });
  });

  describe('SdkCom', () => {
    const apiVersion = {
      assetInfo: '1.0.0',
      chainHistory: '3.1.0',
      handle: '1.0.0',
      networkInfo: '1.0.0',
      rewards: '1.0.0',
      root: '1.0.0',
      stakePool: '1.1.0',
      txSubmit: '2.0.0',
      utxo: '2.0.0'
    };

    const mockPost = jest.fn();

    beforeEach(() => {
      mockPost.mockClear();
    });

    it('fetches tip using insecure connection', () => {
      const sdkComInsecure = new k6Utils.SdkCom({
        apiVersion,
        dut: localDUT,
        k6Http: { post: mockPost as unknown as typeof http.post },
        secure: false
      });
      sdkComInsecure.tip();
      expect(mockPost.mock.calls[0][0]).toEqual('http://localhost:3000/v1.0.0/network-info/ledger-tip');
    });

    it('fetches rewards balance using connection', () => {
      const sdkCom = new k6Utils.SdkCom({
        apiVersion,
        dut: localDUT,
        k6Http: { post: mockPost as unknown as typeof http.post }
      });
      sdkCom.rewardsAccBalance('acct' as Cardano.RewardAccount);
      expect(mockPost.mock.calls[0][0]).toEqual('https://localhost:3000/v1.0.0/rewards/account-balance');
    });

    it.todo('more tests would be nice but it would lead to a duplication of cardano-services-client code & tests');
  });
});
