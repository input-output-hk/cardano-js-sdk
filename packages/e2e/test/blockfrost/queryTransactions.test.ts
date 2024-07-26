import * as envalid from 'envalid';
import { Cardano, ChainHistoryProvider, InvalidStringError } from '@cardano-sdk/core';
import { chainHistoryProviderFactory } from '../../src/factories';
import { logger } from '@cardano-sdk/util-dev';

// Verify environment.
export const env = envalid.cleanEnv(process.env, {
  CHAIN_HISTORY_PROVIDER: envalid.str(),
  CHAIN_HISTORY_PROVIDER_PARAMS: envalid.json({ default: {} })
});

describe('blockfrostChainHistoryProvider', () => {
  let chainHistoryProvider: ChainHistoryProvider;

  beforeAll(async () => {
    chainHistoryProvider = await chainHistoryProviderFactory.create(
      env.CHAIN_HISTORY_PROVIDER,
      env.CHAIN_HISTORY_PROVIDER_PARAMS,
      logger
    );
  });

  describe('transactionsByHashes', () => {
    it('parses metadata correctly', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('84801fb64a9c5078c406ead24017ba0b069ef6ac6446fef8bdb8f97bade3cfa5')]
      });
      expect(tx.auxiliaryData!.body.blob!.get(9_223_372_036_854_775_707n)).toEqual(
        '9223372036854775707922337203685477570792233720368547757079223372'
      );
    });

    // TODO: waiting for resolution of
    // https://github.com/blockfrost/openapi/issues/211
    it.skip('parses collaterals correctly', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('12fa9af65e21b36ec4dc4cbce478e911d52585adb46f2b4fe3d6563e7ee5a61a')]
      });
      expect(tx.body.inputs!.length).toEqual(1);
      expect(tx.body.outputs!.length).toEqual(1);
      expect(tx.body.collaterals!.length).toEqual(2);
      expect(tx.body.collaterals![0]).toEqual({
        address:
          'addr_test1qrv0j69s06vd56365fsh5ync44ykaqr4exwf2vt6tuv76' +
          'lcxy8jmk9rapjmuk2e7cfmshs27r4sx7tk0q3afktjf7j2qvdncx7',
        index: 1,
        txId: '2db6592c4782064295295b365c2e8ce84084fa24b1b3f5834f3c6b65268b7878'
      });
    });
    // TODO: waiting for release/deploy in db-sync/blockfrost
    // https://github.com/input-output-hk/cardano-db-sync/issues/1019
    it.skip('has collaterals for failed contract', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('9298f499a4c4aeba53a984cb4df0f9a93b7d158da4c2c2d12a06530841f94cd7')]
      });
      expect(tx.body.inputs!.length).toEqual(0);
      expect(tx.body.outputs!.length).toEqual(0);
      expect(tx.body.collaterals!.length).toEqual(1);
    });
    it('has withdrawals', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('e92e3c2ce94d61449876e23ba9170ca20868ee447f13703c5fa7e888cc1701e1')]
      });
      expect(tx.body.withdrawals).toEqual([
        { quantity: 29_308_336n, stakeAddress: 'stake_test1urlhkh2pl2xt24dkgjtqrkzfv77ekqj950znqpzdsz2wuds0xlsk6' }
      ]);
    });
    it('has redeemer', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('3353309c6d3f2200c4e2084f76c1f1495f00eb21ea62f29c01da2adac71e1068')]
      });
      expect(tx.witness.redeemers).toEqual([
        {
          executionUnits: { memory: 555_670, steps: 229_163_102 },
          index: 0,
          purpose: 'mint',
          scriptHash: '87c822cd8fb44f2e3bffc3eaf41c63c2301a0ac2325ee3db634bd435'
        }
      ]);
    });
    // TODO: not implemented
    it.skip('has mint', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('c09d19f5ac172e35dbeb7b279d54de73f7e997e49ca812e446fa362a43b71b58')]
      });
      expect(tx.body.mint!).toBeDefined();
    });
    it('has StakeKeyRegistration cert', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('bcd165c882dc17a416bfef7053f0e1cfc3d715f8d7fc05a9803309f795878d9b')]
      });
      expect(tx.body.certificates![0]).toEqual({
        __typename: 'StakeKeyRegistrationCertificate',
        stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(
          Cardano.RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv')
        )
      });
    });
    it('has StakeDelegation cert', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('bcd165c882dc17a416bfef7053f0e1cfc3d715f8d7fc05a9803309f795878d9b')]
      });
      expect(tx.body.certificates![1]).toEqual({
        __typename: 'StakeDelegationCertificate',
        poolId: 'pool167u07rzwu6dr40hx2pr4vh592vxp4zen9ct2p3h84wzqzv6fkgv',
        stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(
          Cardano.RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv')
        )
      });
    });
    it('has StakeKeyDeregistration cert', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('150a445f4d1f2e692791daec9c09f32d6c8c25a3f9ca6c7cf14ff8085375aaa0')]
      });
      expect(tx.body.certificates![0]).toEqual({
        __typename: 'StakeKeyDeregistrationCertificate',
        stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(
          Cardano.RewardAccount('stake_test1uqe2twywhfjwt88ghas4sfgq7pp7m8wq64hlhz0vr4uhu2sj2tuzt')
        )
      });
    });
    it('PoolRegistration poolParameters are not implemented (null)', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('295d5e0f7ee182426eaeda8c9f1c63502c72cdf4afd6e0ee0f209adf94a614e7')]
      });
      expect(tx.body.certificates![2]).toEqual({
        __typename: 'PoolRegistrationCertificate',
        poolId: 'pool1y25deq9kldy9y9gfvrpw8zt05zsrfx84zjhugaxrx9ftvwdpua2',
        poolParameters: null
      });
    });
    it('has PoolRetirement cert', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('545ee7080a01aa085be01dffc073020be04ea3283b945c408c0830e9c4f8253c')]
      });
      expect(tx.body.certificates![0]).toEqual({
        __typename: 'PoolRetirementCertificate',
        epoch: 80,
        poolId: 'pool1ky9w02c4m4y842ygc0jyaf908wgllxv3cvpx42fd243f7uk664s'
      });
    });
    it('has MoveInstantaneousRewards cert', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('24986c0cd3475419bfb44756c27a0e13a6354a4071153f76a78f9b2d1e596089')]
      });
      expect(tx.body.certificates![0]).toEqual({
        __typename: 'MirCertificate',
        pot: 'treasury',
        quantity: 100_000_000n,
        rewardAccount: 'stake_test1uq6p9hn9u53kvmh4mu98c0d4zzuekp2nkelnynct5g26lqs9yenqu'
      });
    });
    // TODO: blocked by https://github.com/input-output-hk/cardano-db-sync/issues/290
    it.skip('has GenesisKeyDelegation cert', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({ ids: [Cardano.TransactionId('someValue')] });
      expect(tx.body.certificates![0]).toBeDefined();
    });
  });

  describe('transactionsByAddresses', () => {
    it('Shelley address (addr_test1)', async () => {
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg')],
        pagination: { limit: 20, startAt: 0 }
      });

      expect(response.totalResultCount).toBeGreaterThanOrEqual(47);

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('bedfc2ff545ef1ac3cc4d1a06aa67a6d68a663ffb1092f8764390b8a58ef97b4')
        )
      ).toBeDefined();

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('f632b491bb481b4d93fa69e1901ebb623a3af65fde500f1b019eaabd4bb2a980')
        )
      ).toBeDefined();
    });
    it('extended Shelley address (addr_test1)', async () => {
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [
          Cardano.Address(
            'addr_test1qph5x6uahxhxyvtqatzj77sjtjmdjycemt5ncjuj2r4e' +
              'yflkdap42xncd6cazjarce6jh8mx52fcf8ugststvyklj70qhzhe9h'
          )
        ],
        pagination: { limit: 20, startAt: 0 }
      });
      expect(response.totalResultCount).toBeGreaterThanOrEqual(4);

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('a01623f7e3fc679c9f369e06ac0cd942740cade30367b24cedace20a430af1cf')
        )
      ).toBeDefined();

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('667f714ee9d9975ca4fa0f5451e006d3dafcdafb7342fe288ebcaf17c100a996')
        )
      ).toBeDefined();
    });
    it('Icarus Byron address (2c)', async () => {
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [Cardano.Address('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr')],
        pagination: { limit: 20, startAt: 0 }
      });
      expect(response.totalResultCount).toBeGreaterThanOrEqual(1);

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('2822d491a890b40cd2a22003b81a97f63c2b8c373b1b0b8dfa1598739fe34c06')
        )
      ).toBeDefined();
    });
    // Failing because returned transactions are grouped by address
    // TODO: update and reenable test when we decide behaviour
    it.skip('multiple address types', async () => {
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [
          Cardano.Address('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr'),
          Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg'),
          Cardano.Address(
            'addr_test1qph5x6uahxhxyvtqatzj77sjtjmdjycemt5ncjuj2r4e' +
              'yflkdap42xncd6cazjarce6jh8mx52fcf8ugststvyklj70qhzhe9h'
          )
        ],
        pagination: { limit: 20, startAt: 0 }
      });
      expect(response.totalResultCount).toBeGreaterThanOrEqual(52);

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('2822d491a890b40cd2a22003b81a97f63c2b8c373b1b0b8dfa1598739fe34c06')
        )
      ).toBeDefined();

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('667f714ee9d9975ca4fa0f5451e006d3dafcdafb7342fe288ebcaf17c100a996')
        )
      ).toBeDefined();
    });
    it('Shelley address not used - no transactions', async () => {
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [Cardano.Address('addr_test1vrfxjeunkc9xu8rpnhgkluptaq0rm8kyxh8m3q9vtcetjwshvpnsm')],
        pagination: { limit: 20, startAt: 0 }
      });
      expect(response.totalResultCount).toBe(0);
    });
    it('queries successfully invalid transaction (script failure)', async () => {
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg')],
        pagination: { limit: 20, startAt: 0 }
      });

      const invalidTx = response.pageResults.find(
        (tx) => tx.id === Cardano.TransactionId('43149210cbbfbc92bc2b199bb14cb15330414e2288ac31be92a3b5a490f9abfc')
      );
      expect(invalidTx).toBeDefined();
      expect(invalidTx?.body.outputs.length).toEqual(0);
    });

    it('stake address throws error', async () => {
      expect(() => Cardano.Address('stake_test1ur676rnu57m272uvflhm8ahgu8xk980vxg382zye2wpxnjs2dnddx')).toThrowError(
        InvalidStringError
      );
    });

    it('returns transactions starting from blockRange param', async () => {
      const address = Cardano.Address(
        'addr_test1qp88yvfup4eykezr2dytygwyglfzflyn32dh83ftxkzeg4jrdz3th865e0s2cm6xuzc4xkd8desmtu3p5jfmzkazmxwsm2tk5a'
      );
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [address],
        blockRange: { lowerBound: 3_348_548 },
        pagination: { limit: 20, startAt: 0 }
      });

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('264ad5454078db439532e81a5918930779562601b098d6aeae556f785d35e187')
        )
      ).toBeDefined();

      expect(response.totalResultCount).toBeGreaterThanOrEqual(4);
    });
  });
});
