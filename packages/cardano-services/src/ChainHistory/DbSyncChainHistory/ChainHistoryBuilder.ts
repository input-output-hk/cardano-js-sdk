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
  ScriptModel,
  StakeCertModel,
  TransactionDataMap,
  TxIdModel,
  TxInput,
  TxInputModel,
  TxOutMultiAssetModel,
  TxOutScriptMap,
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
  mapPlutusScript,
  mapRedeemer,
  mapTxId,
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

  public async queryTransactionInputsByIds(ids: string[], collateral = false): Promise<TxInput[]> {
    this.#logger.debug(`About to find inputs (collateral: ${collateral}) for transactions with ids:`, ids);
    const result: QueryResult<TxInputModel> = await this.#db.query({
      name: `tx_${collateral ? 'collateral_' : ''}inputs_by_tx_ids`,
      text: collateral ? Queries.findTxCollateralsByIds : Queries.findTxInputsByIds,
      values: [ids]
    });
    return result.rows.length > 0 ? result.rows.map(mapTxInModel) : [];
  }

  public async queryMultiAssetsByTxOut(txOutIds: BigInt[]): Promise<TxOutTokenMap> {
    this.#logger.debug('About to find multi assets for tx outs:', txOutIds);
    const result: QueryResult<TxOutMultiAssetModel> = await this.#db.query({
      name: 'tx_multi_assets_by_tx_out_ids',
      text: Queries.findMultiAssetByTxOut,
      values: [txOutIds]
    });
    return mapTxOutTokenMap(result.rows);
  }

  public async queryReferenceScriptsByTxOut(txOutModel: TxOutputModel[]): Promise<TxOutScriptMap> {
    const txScriptMap: TxOutScriptMap = new Map();

    for (const model of txOutModel) {
      if (model.reference_script_id) {
        const result: QueryResult<ScriptModel> = await this.#db.query({
          name: 'tx_reference_scripts_by_tx_out_ids',
          text: Queries.findReferenceScriptsById,
          values: [[model.reference_script_id]]
        });

        if (result.rows.length === 0) continue;
        if (result.rows[0].type === 'timelock') continue; // Shouldn't happen.

        // There can only be one refScript per output.
        txScriptMap.set(model.id, mapPlutusScript(result.rows[0]));
      }
    }

    return txScriptMap;
  }

  public async queryTransactionOutputsByIds(ids: string[], collateral = false): Promise<TxOutput[]> {
    this.#logger.debug(`About to find outputs (collateral: ${collateral}) for transactions with ids:`, ids);
    const result: QueryResult<TxOutputModel> = await this.#db.query({
      name: `tx_${collateral ? 'collateral_' : ''}outputs_by_tx_ids`,
      text: collateral ? Queries.findCollateralOutputsByTxIds : Queries.findTxOutputsByIds,
      values: [ids]
    });
    if (result.rows.length === 0) return [];

    const txOutIds = result.rows.flatMap((txOut) => BigInt(txOut.id));
    const multiAssets = await this.queryMultiAssetsByTxOut(txOutIds);
    const referenceScripts = await this.queryReferenceScriptsByTxOut(result.rows);

    return result.rows.map((txOut) =>
      mapTxOutModel(txOut, {
        assets: multiAssets.get(txOut.id),
        script: referenceScripts.get(txOut.id)
      })
    );
  }

  public async queryTxMintByIds(ids: string[]): Promise<TxTokenMap> {
    this.#logger.debug('About to find tx mint for transactions with ids:', ids);
    const result: QueryResult<MultiAssetModel> = await this.#db.query({
      name: 'tx_mint_by_tx_ids',
      text: Queries.findTxMintByIds,
      values: [ids]
    });
    return mapTxTokenMap(result.rows);
  }

  public async queryTxRecordIdsByTxHashes(ids: Cardano.TransactionId[]): Promise<string[]> {
    this.#logger.debug('About to find tx mint for transactions with ids:', ids);
    const byteHashes = ids.map((id) => hexStringToBuffer(id));
    const result: QueryResult<{ id: string }> = await this.#db.query({
      name: 'tx_record_ids_by_tx_hashes',
      text: Queries.findTxRecordIdsByTxHashes,
      values: [byteHashes]
    });
    return result.rows.length > 0 ? result.rows.map(({ id }) => id) : [];
  }

  public async queryWithdrawalsByTxIds(ids: string[]): Promise<TransactionDataMap<Cardano.Withdrawal[]>> {
    this.#logger.debug('About to find withdrawals for transactions with ids:', ids);
    const result: QueryResult<WithdrawalModel> = await this.#db.query({
      name: 'tx_withdrawals_by_tx_ids',
      text: Queries.findWithdrawalsByTxIds,
      values: [ids]
    });
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
    const result: QueryResult<RedeemerModel> = await this.#db.query({
      name: 'tx_redeemers_by_tx_ids',
      text: Queries.findRedeemersByTxIds,
      values: [ids]
    });
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
    const poolRetireCerts: QueryResult<PoolRetireCertModel> = await this.#db.query({
      name: 'pool_retire_certs_by_tx_ids',
      text: Queries.findPoolRetireCertsTxIds,
      values: [ids]
    });
    const poolRegisterCerts: QueryResult<PoolRegisterCertModel> = await this.#db.query({
      name: 'pool_registration_certs_by_tx_ids',
      text: Queries.findPoolRegisterCertsByTxIds,
      values: [ids]
    });
    const mirCerts: QueryResult<MirCertModel> = await this.#db.query({
      name: 'pool_mir_certs_by_tx_ids',
      text: Queries.findMirCertsByTxIds,
      values: [ids]
    });
    const stakeCerts: QueryResult<StakeCertModel> = await this.#db.query({
      name: 'pool_stake_certs_by_tx_ids',
      text: Queries.findStakeCertsByTxIds,
      values: [ids]
    });
    const delegationCerts: QueryResult<DelegationCertModel> = await this.#db.query({
      name: 'pool_delegation_certs_by_tx_ids',
      text: Queries.findDelegationCertsByTxIds,
      values: [ids]
    });

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
   * Gets the `tx.id` of the transactions interesting the given set of addresses
   *
   * @param addresses the set of addresses to get transactions
   * @param blockRange optional: the block range within transactions are requested
   * @returns the `tx.id` array
   */
  public async queryTxIdsByAddresses(addresses: Cardano.PaymentAddress[], blockRange?: Range<Cardano.BlockNo>) {
    const rangeForQuery: Range<Cardano.BlockNo> | undefined = blockRange
      ? {
          lowerBound: blockRange.lowerBound ?? (0 as Cardano.BlockNo),
          upperBound: blockRange.upperBound ?? (DB_MAX_SAFE_INTEGER as Cardano.BlockNo)
        }
      : undefined;
    const kind = rangeForQuery ? 'withRange' : 'withoutRange';
    const q = findTxsByAddresses;

    const result = await this.#db.query<TxIdModel>({
      name: `tx_ids_by_addresses${rangeForQuery ? '_with_range' : ''}`,
      text: `${q.WITH}${q[kind].WITH}${q.SELECT}${q[kind].FROM}${q.ORDER}`,
      values: rangeForQuery ? [addresses, rangeForQuery.lowerBound, rangeForQuery.upperBound] : [addresses]
    });

    return result.rows.map(mapTxId);
  }
}
