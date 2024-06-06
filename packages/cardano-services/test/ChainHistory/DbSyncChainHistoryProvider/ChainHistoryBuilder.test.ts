import { Cardano } from '@cardano-sdk/core';
import { ChainHistoryBuilder } from '../../../src/index.js';
import { ChainHistoryFixtureBuilder, TxWith } from '../fixtures/FixtureBuilder.js';
import { DataMocks } from '../../data-mocks/index.js';
import { Pool } from 'pg';
import { createLogger } from '@cardano-sdk/util-dev';
import { hexStringToBuffer } from '@cardano-sdk/util';

const logger = createLogger({ record: true });

/**
 * Checks tx_ids are logged as hex strings
 *
 * @param text the text of the logged message containing tx_ids
 */
const checkLoggedTxIds = (text: string, tx_id?: boolean): void => {
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
  // If this line throws, the logged string is not a record id
  if (tx_id) return expect(tx_ids[0]).toBe(Number(tx_ids[0]).toString());
  // If this line throws, the logged string is not a formally valid tx_id
  Cardano.TransactionId(tx_ids[0] as string);
};

describe('ChainHistoryBuilder', () => {
  let dbConnection: Pool;
  let builder: ChainHistoryBuilder;
  let fixtureBuilder: ChainHistoryFixtureBuilder;

  beforeAll(async () => {
    dbConnection = new Pool({
      connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC
    });
    builder = new ChainHistoryBuilder(dbConnection, logger);
    fixtureBuilder = new ChainHistoryFixtureBuilder(dbConnection, logger);
  });

  afterAll(async () => {
    await dbConnection.end();
  });

  beforeEach(() => logger.reset());

  const getTxId = async (hash: Cardano.TransactionId) => {
    const query = 'SELECT id FROM tx WHERE hash = $1';
    const res = await dbConnection.query<{ id: string }>(query, [hexStringToBuffer(hash)]);

    return res.rowCount ? res.rows[0].id : '0';
  };

  const getTxIds = (hashes: Cardano.TransactionId[]) => Promise.all(hashes.map((_) => getTxId(_)));

  describe('queryTransactionInputsByIds', () => {
    test('query transaction inputs by tx hashes', async () => {
      const ids = await getTxIds(await fixtureBuilder.getTxHashes(1));
      const result = await builder.queryTransactionInputsByIds(ids);
      expect(result.length).toBeGreaterThanOrEqual(1);
      expect(result[0]).toMatchShapeOf(DataMocks.Tx.txInput);
      checkLoggedTxIds('About to find inputs \\(collateral', true);
    });
    test('query transaction inputs with empty array', async () => {
      const result = await builder.queryTransactionInputsByIds([]);
      expect(result).toHaveLength(0);
    });
    test('query transaction inputs when tx hashes not found', async () => {
      const result = await builder.queryTransactionInputsByIds(['0']);
      expect(result).toHaveLength(0);
    });

    describe('with collateral true', () => {
      test('query transaction collateral inputs by tx hashes', async () => {
        const txHashes = await fixtureBuilder.getTxHashes(1, { with: [TxWith.CollateralInput] });
        const ids = await getTxIds(txHashes);
        const result = await builder.queryTransactionInputsByIds(ids, true);
        expect(result).toHaveLength(1);
        expect(result).toMatchShapeOf(DataMocks.Tx.txInput);
      });
      test('query transaction collateral inputs when tx not found or does not have any ', async () => {
        const ids = await getTxIds([
          Cardano.TransactionId('295d5e0f7ee182426eaeda8c9f1c63502c72cdf4afd6e0ee0f209adf94a614e7')
        ]);
        const result = await builder.queryTransactionInputsByIds(['0', ...ids], true);
        expect(result).toHaveLength(0);
      });
    });
  });

  describe('queryTransactionOutputsByIds', () => {
    test('query transaction outputs by tx hashes', async () => {
      const txHashes = await fixtureBuilder.getTxHashes(2);
      const ids = await getTxIds(txHashes);
      const result = await builder.queryTransactionOutputsByIds(ids);
      expect(result.length).toBeGreaterThanOrEqual(2);
      expect(result[0]).toMatchShapeOf(DataMocks.Tx.txOut);
      checkLoggedTxIds('About to find outputs \\(collateral: false\\) for transactions with ids', true);
    });
    test('query transaction outputs with empty array', async () => {
      const result = await builder.queryTransactionOutputsByIds([]);
      expect(result).toHaveLength(0);
    });
    test('query transaction outputs when tx hashes not found', async () => {
      const result = await builder.queryTransactionOutputsByIds(['0']);
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

  describe('queryTxMintByIds', () => {
    test('query transaction mint by tx hashes', async () => {
      const txHashes = await fixtureBuilder.getTxHashes(2, { with: [TxWith.Mint] });
      const ids = await getTxIds(txHashes);
      const result = await builder.queryTxMintByIds(ids);
      expect(result.size).toEqual(2);
      expect(result.get(txHashes[0])).toMatchShapeOf(DataMocks.Tx.txTokenMap);
      checkLoggedTxIds('About to find tx mint for transactions with ids', true);
    });
    test('query transaction mint with empty array', async () => {
      const result = await builder.queryTxMintByIds([]);
      expect(result.size).toEqual(0);
    });
    test('query transaction mint when tx not found or has no mint operations', async () => {
      const ids = await getTxIds([
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      const result = await builder.queryTxMintByIds(['0', ...ids]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryWithdrawalsByTxIds', () => {
    test('query transaction withdrawals by tx hashes', async () => {
      const txHashes = await fixtureBuilder.getTxHashes(1, { with: [TxWith.Withdrawal] });
      const ids = await getTxIds(txHashes);
      const result = await builder.queryWithdrawalsByTxIds(ids);
      expect(result.size).toEqual(1);
      expect(result.get(txHashes[0])).toMatchShapeOf(DataMocks.Tx.withdrawal);
      checkLoggedTxIds('About to find withdrawals for transactions with ids', true);
    });
    test('query transaction withdrawals with empty array', async () => {
      const result = await builder.queryWithdrawalsByTxIds([]);
      expect(result.size).toEqual(0);
    });
    test('query transaction withdrawals when tx not found or has no withdrawals', async () => {
      const ids = await getTxIds([
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      const result = await builder.queryWithdrawalsByTxIds(['0', ...ids]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryRedeemersByIds', () => {
    test('query transaction redeemers by tx hashes', async () => {
      const txHashes = await fixtureBuilder.getTxHashes(1, { with: [TxWith.Redeemer] });
      const ids = await getTxIds(txHashes);
      const result = await builder.queryRedeemersByIds(ids);
      expect(result.size).toEqual(1);
      expect(result.get(txHashes[0])![0]).toMatchShapeOf(DataMocks.Tx.redeemer);
      checkLoggedTxIds('About to find redeemers for transactions with ids', true);
    });
    test('query transaction redeemers with empty array', async () => {
      const result = await builder.queryRedeemersByIds([]);
      expect(result.size).toEqual(0);
    });
    test('query transaction redeemers when tx not found or has no redeemers', async () => {
      const ids = await getTxIds([
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      const result = await builder.queryRedeemersByIds(['0', ...ids]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryCertificatesByIds', () => {
    test('query certificates by tx hashes', async () => {
      const txHashes = await fixtureBuilder.getTxHashes(2, { with: [TxWith.DelegationCertificate] });
      const ids = await getTxIds(txHashes);
      const result = await builder.queryCertificatesByIds(ids);
      expect(result.size).toBeGreaterThanOrEqual(2);
      const certificates = result.get(txHashes[0]);
      let delegationCertificate;
      for (let i = 0; i < certificates!.length; ++i) {
        if (certificates![i].__typename === 'StakeDelegationCertificate') delegationCertificate = certificates![i];
      }
      expect(delegationCertificate).toBeDefined();
      expect(delegationCertificate).toMatchShapeOf(DataMocks.Tx.certificate);
      checkLoggedTxIds('About to find certificates for transactions with ids', true);
    });
    test('query certificates with empty array', async () => {
      const result = await builder.queryCertificatesByIds([]);
      expect(result.size).toEqual(0);
    });
    test('query certificates when tx not found or has not certificates', async () => {
      const ids = await getTxIds([
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      const result = await builder.queryCertificatesByIds(['0', ...ids]);
      expect(result.size).toEqual(0);
    });
  });
});
