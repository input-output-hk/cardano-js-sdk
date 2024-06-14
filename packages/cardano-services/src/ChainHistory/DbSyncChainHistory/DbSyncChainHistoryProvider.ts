/* eslint-disable sonarjs/no-nested-template-literals */
import * as Queries from './queries';
import { BlockModel, BlockOutputModel, TipModel, TxModel } from './types';
import {
  BlocksByIdsArgs,
  Cardano,
  ChainHistoryProvider,
  Paginated,
  ProviderError,
  ProviderFailure,
  TransactionsByAddressesArgs,
  TransactionsByIdsArgs
} from '@cardano-sdk/core';
import { ChainHistoryBuilder } from './ChainHistoryBuilder';
import { DB_MAX_SAFE_INTEGER } from './queries';
import { DbSyncProvider, DbSyncProviderDependencies } from '../../util/DbSyncProvider';
import { QueryResult } from 'pg';
import { TxMetadataService } from '../../Metadata';
import { hexStringToBuffer } from '@cardano-sdk/util';
import { mapBlock, mapTxAlonzo, mapTxIn, mapTxOut } from './mappers';
import orderBy from 'lodash/orderBy.js';

/** Properties that are need to create DbSyncChainHistoryProvider */
export interface ChainHistoryProviderProps {
  /** Pagination page size limit used for provider methods constraint. */
  paginationPageSizeLimit: number;
}

/** Dependencies that are need to create DbSyncChainHistoryProvider */
export interface ChainHistoryProviderDependencies extends DbSyncProviderDependencies {
  /** The TxMetadataService to retrieve transactions metadata by hashes. */
  metadataService: TxMetadataService;
}

export class DbSyncChainHistoryProvider extends DbSyncProvider() implements ChainHistoryProvider {
  #paginationPageSizeLimit: number;
  #builder: ChainHistoryBuilder;
  #metadataService: TxMetadataService;

  constructor(
    { paginationPageSizeLimit }: ChainHistoryProviderProps,
    { cache, dbPools, cardanoNode, metadataService, logger }: ChainHistoryProviderDependencies
  ) {
    super({ cache, cardanoNode, dbPools, logger });
    this.#builder = new ChainHistoryBuilder(dbPools.main, logger);
    this.#metadataService = metadataService;
    this.#paginationPageSizeLimit = paginationPageSizeLimit;
  }

  public async transactionsByAddresses({
    addresses,
    pagination,
    blockRange
  }: TransactionsByAddressesArgs): Promise<Paginated<Cardano.HydratedTx>> {
    if (addresses.length > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `Addresses count of ${addresses.length} can not be greater than ${this.#paginationPageSizeLimit}`
      );
    }

    if (pagination.limit > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `Page size of ${pagination.limit} can not be greater than ${this.#paginationPageSizeLimit}`
      );
    }

    const lowerBound = blockRange?.lowerBound ?? 0;
    const upperBound = blockRange?.upperBound ?? DB_MAX_SAFE_INTEGER;

    this.logger.debug(
      `About to find transactions of addresses ${addresses} ${
        blockRange?.lowerBound ? `since block ${lowerBound}` : ''
      } ${blockRange?.upperBound ? `and before ${upperBound}` : ''}`
    );

    const allIds = await this.#builder.queryTxIdsByAddresses(addresses, blockRange);
    const totalResultCount = allIds.length;
    const ids = allIds.splice(pagination.startAt, pagination.limit);

    return { pageResults: totalResultCount ? await this.transactionsByIds(ids) : [], totalResultCount };
  }

  public async transactionsByHashes({ ids }: TransactionsByIdsArgs): Promise<Cardano.HydratedTx[]> {
    if (ids.length > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `Transaction ids count of ${ids.length} can not be greater than ${this.#paginationPageSizeLimit}`
      );
    }

    // Conversion tx.hash -> tx.id
    const txRecordIds = await this.#builder.queryTxRecordIdsByTxHashes(ids);
    return this.transactionsByIds(txRecordIds);
  }

  private async transactionsByIds(ids: string[]): Promise<Cardano.HydratedTx[]> {
    this.logger.debug('About to find transactions with ids:', ids);
    const txResults: QueryResult<TxModel> = await this.dbPools.main.query({
      name: 'transactions_by_ids',
      text: Queries.findTransactionsByIds,
      values: [ids]
    });
    if (txResults.rows.length === 0) return [];

    const [
      inputs,
      outputs,
      mints,
      withdrawals,
      redeemers,
      metadata,
      collaterals,
      certificates,
      collateralOutputs,
      votingProcedures,
      proposalProcedures
    ] = await Promise.all([
      this.#builder.queryTransactionInputsByIds(ids),
      this.#builder.queryTransactionOutputsByIds(ids),
      this.#builder.queryTxMintByIds(ids),
      this.#builder.queryWithdrawalsByTxIds(ids),
      this.#builder.queryRedeemersByIds(ids),
      // Missing witness datums
      this.#metadataService.queryTxMetadataByRecordIds(ids),
      this.#builder.queryTransactionInputsByIds(ids, true),
      this.#builder.queryCertificatesByIds(ids),
      this.#builder.queryTransactionOutputsByIds(ids, true),
      this.#builder.queryVotingProceduresByIds(ids),
      this.#builder.queryProposalProceduresByIds(ids)
    ]);

    return txResults.rows.map((tx) => {
      const txId = tx.id.toString('hex') as unknown as Cardano.TransactionId;
      const txInputs = orderBy(inputs.filter((input) => input.txInputId === txId).map(mapTxIn), ['index']);
      const txCollaterals = orderBy(collaterals.filter((col) => col.txInputId === txId).map(mapTxIn), ['index']);
      const txOutputs = orderBy(outputs.filter((output) => output.txId === txId).map(mapTxOut), ['index']);
      const txCollateralOutputs = orderBy(collateralOutputs.filter((output) => output.txId === txId).map(mapTxOut), [
        'index'
      ]);
      const inputSource: Cardano.InputSource = tx.valid_contract
        ? Cardano.InputSource.inputs
        : Cardano.InputSource.collaterals;

      return mapTxAlonzo(tx, {
        certificates: certificates.get(txId),
        collateralOutputs: txCollateralOutputs,
        collaterals: txCollaterals,
        inputSource,
        inputs: txInputs,
        metadata: metadata.get(txId),
        mint: mints.get(txId),
        outputs: txOutputs,
        proposalProcedures: proposalProcedures.get(txId),
        redeemers: redeemers.get(txId),
        votingProcedures: votingProcedures.get(txId),
        withdrawals: withdrawals.get(txId)
      });
    });
  }

  public async blocksByHashes({ ids }: BlocksByIdsArgs): Promise<Cardano.ExtendedBlockInfo[]> {
    if (ids.length > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `Block ids count of ${ids.length} can not be greater than ${this.#paginationPageSizeLimit}`
      );
    }

    this.logger.debug('About to find network tip');
    const tipResult: QueryResult<TipModel> = await this.dbPools.main.query(Queries.findTip);
    const tip: TipModel = tipResult.rows[0];
    if (!tip) return [];

    const byteIds = ids.map((id) => hexStringToBuffer(id));
    this.logger.debug('About to find blocks with hashes:', byteIds);
    const blocksResult: QueryResult<BlockModel> = await this.dbPools.main.query(Queries.findBlocksByHashes, [byteIds]);
    if (blocksResult.rows.length === 0) return [];

    this.logger.debug('About to find blocks outputs and fees for blocks:', byteIds);
    const outputResult: QueryResult<BlockOutputModel> = await this.dbPools.main.query(
      Queries.findBlocksOutputByHashes,
      [byteIds]
    );

    return blocksResult.rows.map((block) => {
      const blockOutput = outputResult.rows.find((output) => output.hash === block.hash) ?? {
        fees: '0',
        hash: block.hash,
        output: '0'
      };

      return mapBlock(block, blockOutput, tip);
    });
  }
}
