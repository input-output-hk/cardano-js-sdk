import * as Queries from './queries';
import { Cardano } from '@cardano-sdk/core';
import {
  CertificateModel,
  DelegationCertModel,
  MirCertModel,
  MultiAssetModel,
  PoolRegisterCertModel,
  PoolRetireCertModel,
  RedeemerModel,
  StakeCertModel,
  TransactionDataMap,
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
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import { hexStringToBuffer } from '@cardano-sdk/util';
import {
  mapCertificate,
  mapRedeemer,
  mapTxInModel,
  mapTxOutModel,
  mapTxOutTokenMap,
  mapTxTokenMap,
  mapWithdrawal
} from './mappers';
import omit from 'lodash/omit';
import orderBy from 'lodash/orderBy';

export class ChainHistoryBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async queryTransactionInputsByHashes(hashes: Cardano.TransactionId[], collateral = false): Promise<TxInput[]> {
    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash.toString()));
    this.#logger.debug(`About to find inputs (collateral: ${collateral}) for transactions:`, byteHashes);
    const result: QueryResult<TxInputModel> = await this.#db.query(
      collateral ? Queries.findTxCollateralsByHashes : Queries.findTxInputsByHashes,
      [byteHashes]
    );
    return result.rows.length > 0 ? result.rows.map(mapTxInModel) : [];
  }

  public async queryMultiAssetsByTxOut(txOutIds: BigInt[]): Promise<TxOutTokenMap> {
    this.#logger.debug('About to find multi assets for tx outs:', txOutIds);
    const result: QueryResult<TxOutMultiAssetModel> = await this.#db.query(Queries.findMultiAssetByTxOut, [txOutIds]);
    return mapTxOutTokenMap(result.rows);
  }

  public async queryTransactionOutputsByHashes(hashes: Cardano.TransactionId[]): Promise<TxOutput[]> {
    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash.toString()));
    this.#logger.debug('About to find outputs for transactions:', byteHashes);
    const result: QueryResult<TxOutputModel> = await this.#db.query(Queries.findTxOutputsByHashes, [byteHashes]);
    if (result.rows.length === 0) return [];

    const txOutIds = result.rows.flatMap((txOut) => BigInt(txOut.id));
    const multiAssets = await this.queryMultiAssetsByTxOut(txOutIds);
    return result.rows.map((txOut) => mapTxOutModel(txOut, multiAssets.get(txOut.id)));
  }

  public async queryTxMintByHashes(hashes: Cardano.TransactionId[]): Promise<TxTokenMap> {
    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash.toString()));
    this.#logger.debug('About to find tx mint for txs:', byteHashes);
    const result: QueryResult<MultiAssetModel> = await this.#db.query(Queries.findTxMint, [byteHashes]);
    return mapTxTokenMap(result.rows);
  }

  public async queryWithdrawalsByHashes(
    hashes: Cardano.TransactionId[]
  ): Promise<TransactionDataMap<Cardano.Withdrawal[]>> {
    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash.toString()));
    this.#logger.debug('About to find withdrawals for txs:', byteHashes);
    const result: QueryResult<WithdrawalModel> = await this.#db.query(Queries.findWithdrawal, [byteHashes]);
    const withdrawalMap: TransactionDataMap<Cardano.Withdrawal[]> = new Map();
    for (const withdrawal of result.rows) {
      const txId = withdrawal.tx_id.toString('hex') as unknown as Cardano.TransactionId;
      const currentWithdrawals = withdrawalMap.get(txId) ?? [];
      withdrawalMap.set(txId, [...currentWithdrawals, mapWithdrawal(withdrawal)]);
    }
    return withdrawalMap;
  }

  public async queryRedeemersByHashes(
    hashes: Cardano.TransactionId[]
  ): Promise<TransactionDataMap<Cardano.Redeemer[]>> {
    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash.toString()));
    this.#logger.debug('About to find redeemers for txs:', byteHashes);
    const result: QueryResult<RedeemerModel> = await this.#db.query(Queries.findRedeemer, [byteHashes]);
    const redeemerMap: TransactionDataMap<Cardano.Redeemer[]> = new Map();
    for (const redeemer of result.rows) {
      const txId = redeemer.tx_id.toString('hex') as unknown as Cardano.TransactionId;
      const currentRedeemers = redeemerMap.get(txId) ?? [];
      redeemerMap.set(txId, [...currentRedeemers, mapRedeemer(redeemer)]);
    }
    return redeemerMap;
  }

  public async queryCertificatesByHashes(
    hashes: Cardano.TransactionId[]
  ): Promise<TransactionDataMap<Cardano.Certificate[]>> {
    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash.toString()));
    this.#logger.debug('About to find certificates for txs:', byteHashes);
    const poolRetireCerts: QueryResult<PoolRetireCertModel> = await this.#db.query(Queries.findPoolRetireCerts, [
      byteHashes
    ]);

    const poolRegisterCerts: QueryResult<PoolRegisterCertModel> = await this.#db.query(Queries.findPoolRegisterCerts, [
      byteHashes
    ]);
    const mirCerts: QueryResult<MirCertModel> = await this.#db.query(Queries.findMirCerts, [byteHashes]);
    const stakeCerts: QueryResult<StakeCertModel> = await this.#db.query(Queries.findStakeCerts, [byteHashes]);
    const delegationCerts: QueryResult<DelegationCertModel> = await this.#db.query(Queries.findDelegationCerts, [
      byteHashes
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
}
