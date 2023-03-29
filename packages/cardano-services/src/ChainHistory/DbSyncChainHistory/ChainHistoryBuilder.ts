import * as Queries from './queries';
import { Cardano, PaginationArgs } from '@cardano-sdk/core';
import {
  CertificateModel,
  CountModel,
  DelegationCertModel,
  MirCertModel,
  MultiAssetModel,
  PoolRegisterCertModel,
  PoolRetireCertModel,
  RedeemerModel,
  StakeCertModel,
  TransactionDataMap,
  TxIdModel,
  TxInput,
  TxInputModel,
  TxOutMultiAssetModel,
  TxOutTokenMap,
  TxOutput,
  TxOutputModel,
  TxTokenMap,
  WithCertIndex,
  WithCertType,
  WithdrawalModel
} from './types';
import { DB_MAX_SAFE_INTEGER, findTxsByAddresses } from './queries';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import { Range, hexStringToBuffer } from '@cardano-sdk/util';
import {
  mapCertificate,
  mapRedeemer,
  mapTxId,
  mapTxInModel,
  mapTxOutModel,
  mapTxOutTokenMap,
  mapTxTokenMap,
  mapWithdrawal
} from './mappers';
import { withPagination } from '../../StakePool/DbSyncStakePoolProvider/queries';
import omit from 'lodash/omit';
import orderBy from 'lodash/orderBy';

export class ChainHistoryBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async queryTransactionInputsByIds(ids: string[], collateral = false): Promise<TxInput[]> {
    this.#logger.debug(`About to find inputs (collateral: ${collateral}) for transactions with ids:`, ids);
    const result: QueryResult<TxInputModel> = await this.#db.query(
      collateral ? Queries.findTxCollateralsByIds : Queries.findTxInputsByIds,
      [ids]
    );
    return result.rows.length > 0 ? result.rows.map(mapTxInModel) : [];
  }

  public async queryMultiAssetsByTxOut(txOutIds: BigInt[]): Promise<TxOutTokenMap> {
    this.#logger.debug('About to find multi assets for tx outs:', txOutIds);
    const result: QueryResult<TxOutMultiAssetModel> = await this.#db.query(Queries.findMultiAssetByTxOut, [txOutIds]);
    return mapTxOutTokenMap(result.rows);
  }

  public async queryTransactionOutputsByIds(ids: string[]): Promise<TxOutput[]> {
    this.#logger.debug('About to find outputs for transactions with ids:', ids);
    const result: QueryResult<TxOutputModel> = await this.#db.query(Queries.findTxOutputsByIds, [ids]);
    if (result.rows.length === 0) return [];

    const txOutIds = result.rows.flatMap((txOut) => BigInt(txOut.id));
    const multiAssets = await this.queryMultiAssetsByTxOut(txOutIds);
    return result.rows.map((txOut) => mapTxOutModel(txOut, multiAssets.get(txOut.id)));
  }

  public async queryTxMintByIds(ids: string[]): Promise<TxTokenMap> {
    this.#logger.debug('About to find tx mint for transactions with ids:', ids);
    const result: QueryResult<MultiAssetModel> = await this.#db.query(Queries.findTxMintByIds, [ids]);
    return mapTxTokenMap(result.rows);
  }

  public async queryTxRecordIdsByTxHashes(ids: Cardano.TransactionId[]): Promise<string[]> {
    this.#logger.debug('About to find tx mint for transactions with ids:', ids);
    const byteHashes = ids.map((id) => hexStringToBuffer(id));
    const result: QueryResult<{ id: string }> = await this.#db.query(Queries.findTxRecordIdsByTxHashes, [byteHashes]);
    return result.rows.length > 0 ? result.rows.map(({ id }) => id) : [];
  }

  public async queryWithdrawalsByTxIds(ids: string[]): Promise<TransactionDataMap<Cardano.Withdrawal[]>> {
    this.#logger.debug('About to find withdrawals for transactions with ids:', ids);
    const result: QueryResult<WithdrawalModel> = await this.#db.query(Queries.findWithdrawalsByTxIds, [ids]);
    const withdrawalMap: TransactionDataMap<Cardano.Withdrawal[]> = new Map();
    for (const withdrawal of result.rows) {
      const txId = withdrawal.tx_id.toString('hex') as unknown as Cardano.TransactionId;
      const currentWithdrawals = withdrawalMap.get(txId) ?? [];
      withdrawalMap.set(txId, [...currentWithdrawals, mapWithdrawal(withdrawal)]);
    }
    return withdrawalMap;
  }

  public async queryRedeemersByIds(ids: string[]): Promise<TransactionDataMap<Cardano.Redeemer[]>> {
    this.#logger.debug('About to find redeemers for transactions with ids:', ids);
    const result: QueryResult<RedeemerModel> = await this.#db.query(Queries.findRedeemersByTxIds, [ids]);
    const redeemerMap: TransactionDataMap<Cardano.Redeemer[]> = new Map();
    for (const redeemer of result.rows) {
      const txId = redeemer.tx_id.toString('hex') as unknown as Cardano.TransactionId;
      const currentRedeemers = redeemerMap.get(txId) ?? [];
      redeemerMap.set(txId, [...currentRedeemers, mapRedeemer(redeemer)]);
    }
    return redeemerMap;
  }

  public async queryCertificatesByIds(ids: string[]): Promise<TransactionDataMap<Cardano.Certificate[]>> {
    this.#logger.debug('About to find certificates for transactions with ids:', ids);
    const poolRetireCerts: QueryResult<PoolRetireCertModel> = await this.#db.query(Queries.findPoolRetireCertsTxIds, [
      ids
    ]);
    const poolRegisterCerts: QueryResult<PoolRegisterCertModel> = await this.#db.query(
      Queries.findPoolRegisterCertsByTxIds,
      [ids]
    );
    const mirCerts: QueryResult<MirCertModel> = await this.#db.query(Queries.findMirCertsByTxIds, [ids]);
    const stakeCerts: QueryResult<StakeCertModel> = await this.#db.query(Queries.findStakeCertsByTxIds, [ids]);
    const delegationCerts: QueryResult<DelegationCertModel> = await this.#db.query(Queries.findDelegationCertsByTxIds, [
      ids
    ]);

    // There is currently no way to get GenesisKeyDelegationCertificate from db-sync
    const allCerts: WithCertType<CertificateModel>[] = [
      ...poolRetireCerts.rows.map((cert): WithCertType<PoolRetireCertModel> => ({ ...cert, type: 'retire' })),
      ...poolRegisterCerts.rows.map((cert): WithCertType<PoolRegisterCertModel> => ({ ...cert, type: 'register' })),
      ...mirCerts.rows.map((cert): WithCertType<MirCertModel> => ({ ...cert, type: 'mir' })),
      ...stakeCerts.rows.map((cert): WithCertType<StakeCertModel> => ({ ...cert, type: 'stake' })),
      ...delegationCerts.rows.map((cert): WithCertType<DelegationCertModel> => ({ ...cert, type: 'delegation' }))
    ];
    if (allCerts.length === 0) return new Map();

    const indexedCertsMap: TransactionDataMap<WithCertIndex<Cardano.Certificate>[]> = new Map();
    for (const cert of allCerts) {
      const txId = cert.tx_id.toString('hex') as unknown as Cardano.TransactionId;
      const currentCerts = indexedCertsMap.get(txId) ?? [];
      const newCert = mapCertificate(cert);
      if (newCert) indexedCertsMap.set(txId, [...currentCerts, newCert]);
    }

    const certsMap: TransactionDataMap<Cardano.Certificate[]> = new Map();
    for (const [txId] of indexedCertsMap) {
      const currentCerts = indexedCertsMap.get(txId) ?? [];
      const certs = orderBy(currentCerts, ['cert_index']).map(
        (cert) => omit(cert, 'cert_index') as Cardano.Certificate
      );
      certsMap.set(txId, certs);
    }
    return certsMap;
  }

  /**
   * Gets the paginated `tx.id` or the total count of the transaction interesting the given set of addresses
   *
   * @param addresses the set of addresses to get transaction
   * @param blockRange optional: the block range within transactions are requested
   * @param pagination optional: the pagination of the response
   * @returns the paginated `tx.id` set or, if `pagination` is omitted, the total number of transactions
   */
  public queryTxIdsByAddresses(
    addresses: Cardano.PaymentAddress[],
    blockRange?: Range<Cardano.BlockNo>
  ): Promise<number>;
  public queryTxIdsByAddresses(
    addresses: Cardano.PaymentAddress[],
    blockRange?: Range<Cardano.BlockNo>,
    pagination?: PaginationArgs
  ): Promise<string[]>;
  public async queryTxIdsByAddresses(
    addresses: Cardano.PaymentAddress[],
    blockRange?: Range<Cardano.BlockNo>,
    pagination?: PaginationArgs
  ): Promise<number | string[]> {
    const rangeForQuery: Range<Cardano.BlockNo> | undefined = blockRange
      ? {
          lowerBound: blockRange.lowerBound ?? (0 as Cardano.BlockNo),
          upperBound: blockRange.upperBound ?? (DB_MAX_SAFE_INTEGER as Cardano.BlockNo)
        }
      : undefined;
    const kind = rangeForQuery ? 'withRange' : 'withoutRange';
    const target = pagination ? 'page' : 'count';
    const q = findTxsByAddresses;
    const composedQuery = `${q.WITH}${q[kind].WITH}${q[target].SELECT}${q[kind].FROM}${q[target].ORDER}`;
    const composedArgs = rangeForQuery ? [addresses, rangeForQuery.lowerBound, rangeForQuery.upperBound] : [addresses];

    if (pagination) {
      const { query, args } = withPagination(composedQuery, composedArgs, pagination);
      const result = await this.#db.query<TxIdModel>(query, args);
      return result.rows.map(mapTxId);
    }

    const result = await this.#db.query<CountModel>(composedQuery, composedArgs);
    return Number(result.rows[0].count);
  }
}
