import * as envalid from 'envalid';
import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
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
        ids: [Cardano.TransactionId('5127f8b235111854be744d36703f2098102d2639524035299658e73d683c0dfd')]
      });
      expect(tx.auxiliaryData!.blob!.get(1n)).toEqual(
        new Map<string, string>([
          ['absolute_slot', '67255007'],
          ['timestamp', '1722938207']
        ])
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
        ids: [Cardano.TransactionId('5929a59b9bebad1622f021d13b3d143d88cc92cf2400472e36ed8dcdf598a7fa')]
      });
      expect(tx.body.withdrawals).toEqual([
        { quantity: 26_283_930n, stakeAddress: 'stake_test1urlhkh2pl2xt24dkgjtqrkzfv77ekqj950znqpzdsz2wuds0xlsk6' }
      ]);
    });
    it('has redeemer', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('f0c157c84506f5f3ead133133d6a731c937ebd0df379ed518fdbad9ee53ba28b')]
      });

      expect(tx.witness.redeemers).toBeDefined();
      expect(tx.witness.redeemers).toHaveLength(1);
      expect(tx.witness.redeemers![0].data).toBeDefined();
      expect(tx.witness.redeemers![0]).toMatchObject({
        executionUnits: { memory: 725_365, steps: 281_266_636 },
        index: 0,
        purpose: 'mint'
      });
    });
    // TODO: not implemented
    it.skip('has mint', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('c09d19f5ac172e35dbeb7b279d54de73f7e997e49ca812e446fa362a43b71b58')]
      });
      expect(tx.body.mint!).toBeDefined();
    });
    it('has StakeDelegation cert', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('b8412b0378dfba5442272dbb9de51dc1b462e789b9a1903723679e4549d3f4ef')]
      });
      expect(tx.body.certificates![0]).toEqual({
        __typename: 'StakeDelegationCertificate',
        cert_index: 1,
        poolId: 'pool1z05xqzuxnpl8kg8u2wwg8ftng0fwtdluv3h20ruryfqc5gc3efl',
        stakeCredential: {
          hash: '94917a8771d16a6f0ecfdc53882dbd69710105e0709387fa9358bc99',
          type: 0
        }
      });
    });
    it('has StakeKeyRegistration cert', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('b8412b0378dfba5442272dbb9de51dc1b462e789b9a1903723679e4549d3f4ef')]
      });
      expect(tx.body.certificates![1]).toEqual({
        __typename: 'StakeRegistrationCertificate',
        cert_index: 0,
        stakeCredential: {
          hash: '94917a8771d16a6f0ecfdc53882dbd69710105e0709387fa9358bc99',
          type: 0
        }
      });
    });
    it('has StakeKeyDeregistration cert', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('78ed92583cd879c56e4dd49c06af303aa52e127074eac1123f727ed7eef36084')]
      });
      expect(tx.body.certificates![0]).toEqual({
        __typename: 'StakeDeregistrationCertificate',
        cert_index: 0,
        stakeCredential: {
          hash: '94917a8771d16a6f0ecfdc53882dbd69710105e0709387fa9358bc99',
          type: 0
        }
      });
    });
    it('PoolRegistration poolParameters are not implemented (null)', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('17dff81aef66f0955963a06e1a63e35e60b3b89474f7c1277254dae6cf8592b8')]
      });
      expect(tx.body.certificates![1]).toEqual({
        __typename: 'PoolRegistrationCertificate',
        cert_index: 0,
        poolId: 'pool1z05xqzuxnpl8kg8u2wwg8ftng0fwtdluv3h20ruryfqc5gc3efl',
        poolParameters: null
      });
    });
    it('has PoolRetirement cert', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('a6cfa382e0b41bb227a6ed8ce2eb58ec16f78fb6e0961f8824ca2039667c801f')]
      });
      expect(tx.body.certificates![0]).toEqual({
        __typename: 'PoolRetirementCertificate',
        cert_index: 0,
        epoch: 152,
        poolId: 'pool1mvgpsafktxs883p66awp7fplj73cj6j9hqdxzvqw494f7f0v2dp'
      });
    });
    it.skip('has MoveInstantaneousRewards cert', async () => {
      // @todo there is no Instantaneous Rewards in preprod https://preprod.beta.explorer.cardano.org/en/instantaneous-rewards
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
        addresses: [Cardano.PaymentAddress('addr_test1vz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzerspjrlsz')],
        pagination: { limit: 20, startAt: 0 }
      });

      expect(response.totalResultCount).toBeGreaterThanOrEqual(8);

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('63b3fb0640cd6bc4c093e70aa8b9d0051f5afc99ad60e181da399fb4db230b0f')
        )
      ).toBeDefined();

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('6966174b495070898e9525158a1aaf2b2ee7976ea27bfdac9ca060d98160c204')
        )
      ).toBeDefined();
    });
    it('extended Shelley address (addr_test1)', async () => {
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [
          Cardano.PaymentAddress(
            'addr_test1qpvqf0y9sgpn92crff8cxrl95s0veay4gude7pgdn0tlvwv5j9agwuw3dfhsan7u2wyzm0tfwyqstcrsjwrl4y6chjvsneezuv'
          )
        ],
        pagination: { limit: 20, startAt: 0 }
      });
      expect(response.totalResultCount).toBeGreaterThanOrEqual(3);

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('78ed92583cd879c56e4dd49c06af303aa52e127074eac1123f727ed7eef36084')
        )
      ).toBeDefined();

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('b8412b0378dfba5442272dbb9de51dc1b462e789b9a1903723679e4549d3f4ef')
        )
      ).toBeDefined();
    });
    it('Icarus Byron address (2c)', async () => {
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [Cardano.PaymentAddress('2cWKMJemoBahPCkbVybbhitWU1HQt6GV6J6CVtPp2TsbBKD5LLYdcNXaxQtNQnaYdrpfg')],
        pagination: { limit: 20, startAt: 0 }
      });
      expect(response.totalResultCount).toBeGreaterThanOrEqual(1);

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('1fb751b36dd7a237ddf6b6a0d681041cdce3b5775c72dcc7972f5c292c3c2e8b')
        )
      ).toBeDefined();
    });
    // Failing because returned transactions are grouped by address
    // TODO: update and reenable test when we decide behaviour
    it.skip('multiple address types', async () => {
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [
          Cardano.PaymentAddress('2cWKMJemoBai9J7kVvRTukMmdfxtjL9z7c396rTfrrzfAZ6EeQoKLC2y1k34hswwm4SVr'),
          Cardano.PaymentAddress('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg'),
          Cardano.PaymentAddress(
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
        addresses: [Cardano.PaymentAddress('addr_test1vrfxjeunkc9xu8rpnhgkluptaq0rm8kyxh8m3q9vtcetjwshvpnsm')],
        pagination: { limit: 20, startAt: 0 }
      });
      expect(response.totalResultCount).toBe(0);
    });
    it.skip('queries successfully invalid transaction (script failure)', async () => {
      // @todo find a script failure in preprod
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [Cardano.PaymentAddress('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg')],
        pagination: { limit: 20, startAt: 0 }
      });

      const invalidTx = response.pageResults.find(
        (tx) => tx.id === Cardano.TransactionId('FHnt4NL7yPYH2vP2FLEfH2pt3K6meM7fgtjRiLBidaqpP5ogPzxLNsZy68e1KdW')
      );
      expect(invalidTx).toBeDefined();
      expect(invalidTx?.body.outputs.length).toEqual(0);
    });

    it('stake address throws error', async () => {
      expect(() =>
        Cardano.PaymentAddress('stake_test1ur676rnu57m272uvflhm8ahgu8xk980vxg382zye2wpxnjs2dnddx')
      ).toThrowError();
    });

    it('returns transactions starting from blockRange param', async () => {
      const address = Cardano.PaymentAddress(
        'addr_test1qpvqf0y9sgpn92crff8cxrl95s0veay4gude7pgdn0tlvwv5j9agwuw3dfhsan7u2wyzm0tfwyqstcrsjwrl4y6chjvsneezuv'
      );
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [address],
        blockRange: { lowerBound: Cardano.BlockNo(3_348_548) },
        pagination: { limit: 20, startAt: 0 }
      });

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('78ed92583cd879c56e4dd49c06af303aa52e127074eac1123f727ed7eef36084')
        )
      ).toBeUndefined();

      expect(response.totalResultCount).toBeGreaterThanOrEqual(3);
    });
  });
});
