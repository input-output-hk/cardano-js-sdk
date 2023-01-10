import { Cardano } from '@cardano-sdk/core';
import { ChainHistoryBuilder } from '../../../src';
import { ChainHistoryFixtureBuilder, TxWith } from '../fixtures/FixtureBuilder';
import { DataMocks } from '../../data-mocks';
import { Pool } from 'pg';
import { createLogger } from '@cardano-sdk/util-dev';

const logger = createLogger({ record: true });

/**
 * Checks tx_ids are logged as hex strings
 *
 * @param text the text of the loggd message containing tx_ids
 */
const checkLoggedTxids = (text: string): void => {
  //
  const messages = logger.messages.filter(
    (_) => _.level === 'debug' && typeof _.message[0] === 'string' && _.message[0].match(text)
  );
  expect(messages.length).toBe(1);
  const { message } = messages[0];
  expect(message.length).toBe(2);
  expect(message[1]).toBeInstanceOf(Array);
  const tx_ids = message[1] as unknown[];
  expect(tx_ids.length).toBeGreaterThan(0);
  expect(typeof tx_ids[0]).toBe('string');
  // If this line throws, the logged string is not a formally valid tx_id
  Cardano.TransactionId(tx_ids[0] as string);
};

describe('ChainHistoryBuilder', () => {
  let dbConnection: Pool;
  let builder: ChainHistoryBuilder;
  let fixtureBuilder: ChainHistoryFixtureBuilder;

  beforeAll(async () => {
    dbConnection = new Pool({
      connectionString: process.env.POSTGRES_CONNECTION_STRING
    });
    builder = new ChainHistoryBuilder(dbConnection, logger);
    fixtureBuilder = new ChainHistoryFixtureBuilder(dbConnection, logger);
  });

  afterAll(async () => {
    await dbConnection.end();
  });

  beforeEach(() => logger.reset());

  describe('queryTransactionInputsByHashes', () => {
    test('query transaction inputs by tx hashes', async () => {
      const txHashes = await fixtureBuilder.getTxHashes(1);
      const result = await builder.queryTransactionInputsByHashes(txHashes);
      expect(result.length).toBeGreaterThanOrEqual(1);
      expect(result[0]).toMatchShapeOf(DataMocks.Tx.txInput);
      checkLoggedTxids('About to find inputs \\(collateral');
    });
    test('query transaction inputs with empty array', async () => {
      const result = await builder.queryTransactionInputsByHashes([]);
      expect(result).toHaveLength(0);
    });
    test('query transaction inputs when tx hashes not found', async () => {
      const result = await builder.queryTransactionInputsByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
      ]);
      expect(result).toHaveLength(0);
    });

    describe('with collateral true', () => {
      test('query transaction collateral inputs by tx hashes', async () => {
        const txHashes = await fixtureBuilder.getTxHashes(1, { with: [TxWith.CollateralInput] });
        const result = await builder.queryTransactionInputsByHashes(txHashes, true);
        expect(result).toHaveLength(1);
        expect(result).toMatchShapeOf(DataMocks.Tx.txInput);
      });
      test('query transaction collateral inputs when tx not found or does not have any ', async () => {
        const result = await builder.queryTransactionInputsByHashes(
          [
            Cardano.TransactionId('295d5e0f7ee182426eaeda8c9f1c63502c72cdf4afd6e0ee0f209adf94a614e7'),
            Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
          ],
          true
        );
        expect(result).toHaveLength(0);
      });
    });
  });

  describe('queryTransactionOutputsByHashes', () => {
    test('query transaction outputs by tx hashes', async () => {
      const txHashes = await fixtureBuilder.getTxHashes(2);
      const result = await builder.queryTransactionOutputsByHashes(txHashes);
      expect(result.length).toBeGreaterThanOrEqual(2);
      expect(result[0]).toMatchShapeOf(DataMocks.Tx.txOut);
      checkLoggedTxids('About to find outputs for transactions');
    });
    test('query transaction outputs with empty array', async () => {
      const result = await builder.queryTransactionOutputsByHashes([]);
      expect(result).toHaveLength(0);
    });
    test('query transaction outputs when tx hashes not found', async () => {
      const result = await builder.queryTransactionOutputsByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
      ]);
      expect(result).toHaveLength(0);
    });
  });

  describe('queryMultiAssetsByTxOut', () => {
    test('query multi assets by tx output', async () => {
      const txOutIds = await fixtureBuilder.getMultiAssetTxOutIds(1);
      const result = await builder.queryMultiAssetsByTxOut(txOutIds);
      const first = [...result.get(txOutIds[0].toString())!][0];

      expect(result.size).toBeGreaterThanOrEqual(1);
      expect(first).toMatchShapeOf(['51873879e6e91d5c52fdf4e065ea38f2d52a492e2aee6d6140c578dd', 0n]);
    });
    test('query multi assets with empty array', async () => {
      const result = await builder.queryMultiAssetsByTxOut([]);
      expect(result.size).toEqual(0);
    });
    test('query multi assets when tx output not found or has no multi-assets', async () => {
      const result = await builder.queryMultiAssetsByTxOut([0n, 5_396_852n]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryTxMintByHashes', () => {
    test('query transaction mint by tx hashes', async () => {
      const txHashes = await fixtureBuilder.getTxHashes(2, { with: [TxWith.Mint] });
      const result = await builder.queryTxMintByHashes(txHashes);
      expect(result.size).toEqual(2);
      expect(result.get(txHashes[0])).toMatchShapeOf(DataMocks.Tx.txTokenMap);
      checkLoggedTxids('About to find tx mint for txs');
    });
    test('query transaction mint with empty array', async () => {
      const result = await builder.queryTxMintByHashes([]);
      expect(result.size).toEqual(0);
    });
    test('query transaction mint when tx not found or has no mint operations', async () => {
      const result = await builder.queryTxMintByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000'),
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryWithdrawalsByHashes', () => {
    test('query transaction withdrawals by tx hashes', async () => {
      const txHashes = await fixtureBuilder.getTxHashes(1, { with: [TxWith.Withdrawal] });
      const result = await builder.queryWithdrawalsByHashes(txHashes);
      expect(result.size).toEqual(1);
      expect(result.get(txHashes[0])).toMatchShapeOf(DataMocks.Tx.withdrawal);
      checkLoggedTxids('About to find withdrawals for txs');
    });
    test('query transaction withdrawals with empty array', async () => {
      const result = await builder.queryWithdrawalsByHashes([]);
      expect(result.size).toEqual(0);
    });
    test('query transaction withdrawals when tx not found or has no withdrawals', async () => {
      const result = await builder.queryWithdrawalsByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000'),
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryRedeemersByHashes', () => {
    test('query transaction redeemers by tx hashes', async () => {
      const txHashes = await fixtureBuilder.getTxHashes(1, { with: [TxWith.Redeemer] });
      const result = await builder.queryRedeemersByHashes(txHashes);
      expect(result.size).toEqual(1);
      expect(result.get(txHashes[0])![0]).toMatchShapeOf(DataMocks.Tx.redeemer);
      checkLoggedTxids('About to find redeemers for txs');
    });
    test('query transaction redeemers with empty array', async () => {
      const result = await builder.queryRedeemersByHashes([]);
      expect(result.size).toEqual(0);
    });
    test('query transaction redeemers when tx not found or has no redeemers', async () => {
      const result = await builder.queryRedeemersByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000'),
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryCertificatesByHashes', () => {
    test('query certificates by tx hashes', async () => {
      const txHashes = await fixtureBuilder.getTxHashes(2, { with: [TxWith.DelegationCertificate] });
      const result = await builder.queryCertificatesByHashes(txHashes);
      expect(result.size).toBeGreaterThanOrEqual(2);
      const certificates = result.get(txHashes[0]);
      let delegationCertificate;
      for (let i = 0; i < certificates!.length; ++i) {
        if (certificates![i].__typename === 'StakeDelegationCertificate') delegationCertificate = certificates![i];
      }
      expect(delegationCertificate).toBeDefined();
      expect(delegationCertificate).toMatchShapeOf(DataMocks.Tx.certificate);
      checkLoggedTxids('About to find certificates for txs');
    });
    test('query certificates with empty array', async () => {
      const result = await builder.queryCertificatesByHashes([]);
      expect(result.size).toEqual(0);
    });
    test('query certificates when tx not found or has not certificates', async () => {
      const result = await builder.queryCertificatesByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000'),
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      expect(result.size).toEqual(0);
    });
  });
});
