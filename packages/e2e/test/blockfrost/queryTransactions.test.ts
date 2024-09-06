import { BlockfrostChainHistoryProvider, util } from '@cardano-sdk/cardano-services';
import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import { logger } from '@cardano-sdk/util-dev';

describe.only('BlockfrostChainHistoryProvider', () => {
  let chainHistoryProvider: ChainHistoryProvider;
  let blockfrost;
  beforeAll(async () => {
    blockfrost = util.getBlockfrostApi();
    chainHistoryProvider = new BlockfrostChainHistoryProvider({
      blockfrost,
      logger
    });
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

    it('has collaterals', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('b3c6c0712e103550de5cd6881a3c735e4d9dce04095628a8c9b1998556499775')]

        //         ids: [Cardano.TransactionId('97abd7079ab871a6d0693f08486df786a0dff24a888953179b60c58c7308c8ee')]
      });
      expect(tx.body.inputs!).toHaveLength(2);
      expect(tx.body.outputs!).toHaveLength(3);
      expect(tx.body.collaterals!).toHaveLength(1);
      expect(tx.body.collaterals![0]).toEqual({
        address: 'addr_test1vrupy5t9ufhxlpt5yd8d7euqz4cqjttz47qeg8yh4z6mu8ssz4vzl',
        index: 0,
        txId: 'b6b1692fd22680e06b136a013f3867eb2b73125671fe4cbe61037f0a5e17ccaa'
      });
    });

    it('has collaterals for failed contract', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('3de3e581ead2b38d6ba1a82a282501e4447d7b6ae28e5fb4a340b9416d5ba6c5')]
      });
      expect(tx.inputSource).toBe(Cardano.InputSource.collaterals);
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

    it('has mint', async () => {
      const [tx] = await chainHistoryProvider.transactionsByHashes({
        ids: [Cardano.TransactionId('695757484882e86079f6723f58b3a83001566d72784236a91fed7746b344d6cd')]
      });
      expect(tx.body.mint!).toBeDefined();
      expect(tx.body.mint!.size).toBe(10);

      const tokenMap = new Map([
        [
          '2511e9ad0baa8c1a662e6eab1da2b7e501d2de729d1a317b909df24f4d656c642042616e6b204d616e61676572207631203739323731353033303537',
          1n
        ],
        [
          '2511e9ad0baa8c1a662e6eab1da2b7e501d2de729d1a317b909df24f4d656c642042616e6b204d616e61676572207631203739323731353037313437',
          1n
        ],
        ['f6f49b186751e61f1fb8c64e7504e771f968cea9f4d11f5222b169e3744d454c44', 64_117_600_456n],
        ['f6f49b186751e61f1fb8c64e7504e771f968cea9f4d11f5222b169e3744d494e', 583_838_935_714n],
        ['f6f49b186751e61f1fb8c64e7504e771f968cea9f4d11f5222b169e374434f5049', 19_282_660_477n],
        ['f6f49b186751e61f1fb8c64e7504e771f968cea9f4d11f5222b169e374484f534b59', 12_750_079_547n],
        ['f6f49b186751e61f1fb8c64e7504e771f968cea9f4d11f5222b169e374574d54', 7_715_787_206n],
        ['f6f49b186751e61f1fb8c64e7504e771f968cea9f4d11f5222b169e3744333', 967_881_787n],
        ['f6f49b186751e61f1fb8c64e7504e771f968cea9f4d11f5222b169e374575254', 3_804_281_695n],
        ['f6f49b186751e61f1fb8c64e7504e771f968cea9f4d11f5222b169e37469555344', 1_112_936_042n]
      ]);
      expect(tx.body.mint!).toEqual(tokenMap);
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
    it('multiple address types', async () => {
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [
          Cardano.PaymentAddress('addr_test1vz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzerspjrlsz'),
          Cardano.PaymentAddress(
            'addr_test1qpvqf0y9sgpn92crff8cxrl95s0veay4gude7pgdn0tlvwv5j9agwuw3dfhsan7u2wyzm0tfwyqstcrsjwrl4y6chjvsneezuv'
          ),
          Cardano.PaymentAddress('2cWKMJemoBahPCkbVybbhitWU1HQt6GV6J6CVtPp2TsbBKD5LLYdcNXaxQtNQnaYdrpfg')
        ],
        pagination: { limit: 100, startAt: 0 }
      });
      expect(response.totalResultCount).toBeGreaterThanOrEqual(12);

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('61eeefa4ab3262d0e66f4decece94dc3fc4d2381d132a0ac18bf7055d4dc3f56')
        )
      ).toBeDefined();

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('b8412b0378dfba5442272dbb9de51dc1b462e789b9a1903723679e4549d3f4ef')
        )
      ).toBeDefined();

      expect(
        response.pageResults.find(
          (tx) => tx.id === Cardano.TransactionId('1fb751b36dd7a237ddf6b6a0d681041cdce3b5775c72dcc7972f5c292c3c2e8b')
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

    it('queries successfully invalid transaction (script failure)', async () => {
      const response = await chainHistoryProvider.transactionsByAddresses({
        addresses: [Cardano.PaymentAddress('addr_test1vqtcml25xg7p6udz6tvyulcnxeysswq8et7r48k8fdzk5kgwlyqxc')],
        pagination: { limit: 20, startAt: 0 }
      });

      const invalidTx = response.pageResults.find(
        (tx) => tx.id === Cardano.TransactionId('3de3e581ead2b38d6ba1a82a282501e4447d7b6ae28e5fb4a340b9416d5ba6c5')
      );
      expect(invalidTx).toBeDefined();
      expect(invalidTx?.inputSource).toBe(Cardano.InputSource.collaterals);
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
      expect(response.pageResults.every((tx) => tx.blockHeader.blockNo >= Cardano.BlockNo(3_348_548))).toBe(true);
    });
  });
});
