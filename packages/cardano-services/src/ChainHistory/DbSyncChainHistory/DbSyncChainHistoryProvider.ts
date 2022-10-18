/* eslint-disable sonarjs/no-nested-template-literals */
import * as Queries from './queries';
import { BlockModel, BlockOutputModel, TipModel, TxInputModel, TxModel, TxOutputModel } from './types';
import {
  BlocksByIdsArgs,
  Cardano,
  CardanoNode,
  ChainHistoryProvider,
  Paginated,
  ProviderError,
  ProviderFailure,
  TransactionsByAddressesArgs,
  TransactionsByIdsArgs
} from '@cardano-sdk/core';
import { ChainHistoryBuilder } from './ChainHistoryBuilder';
import { DB_MAX_SAFE_INTEGER } from './queries';
import { DbSyncProvider } from '../../util/DbSyncProvider';
import { Logger } from 'ts-log';
import { MetadataService } from '../../Metadata';
import { Pool, QueryResult } from 'pg';
import { applyPagination } from './util';
import { hexStringToBuffer } from '@cardano-sdk/util';
import { mapBlock, mapTxAlonzo, mapTxIn, mapTxInModel, mapTxOut, mapTxOutModel } from './mappers';
import orderBy from 'lodash/orderBy';
import uniq from 'lodash/uniq';
export interface ChainHistoryProviderProps {
  paginationPageSizeLimit: number;
}
export interface ChainHistoryProviderDependencies {
  db: Pool;
  cardanoNode: CardanoNode;
  metadataService: MetadataService;
  logger: Logger;
}
export class DbSyncChainHistoryProvider extends DbSyncProvider() implements ChainHistoryProvider {
  #paginationPageSizeLimit: number;
  #builder: ChainHistoryBuilder;
  #metadataService: MetadataService;
  #logger: Logger;

  constructor(
    { paginationPageSizeLimit }: ChainHistoryProviderProps,
    { db, cardanoNode, metadataService, logger }: ChainHistoryProviderDependencies
  ) {
    super(db, cardanoNode);
    this.#logger = logger;
    this.#builder = new ChainHistoryBuilder(db, logger);
    this.#metadataService = metadataService;
    this.#paginationPageSizeLimit = paginationPageSizeLimit;
  }

  public async transactionsByAddresses({
    addresses,
    pagination,
    blockRange
  }: TransactionsByAddressesArgs): Promise<Paginated<Cardano.TxAlonzo>> {
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

    this.#logger.debug(
      `About to find transactions of addresses ${addresses} ${
        blockRange?.lowerBound ? `since block ${lowerBound}` : ''
      } ${blockRange?.upperBound ? `and before ${upperBound}` : ''}`
    );

    const inputsResults: QueryResult<TxInputModel> = await this.db.query(Queries.findTxInputsByAddresses, [
      addresses,
      lowerBound,
      upperBound
    ]);
    const outputsResults: QueryResult<TxOutputModel> = await this.db.query(Queries.findTxOutputsByAddresses, [
      addresses,
      lowerBound,
      upperBound
    ]);

    if (inputsResults.rows.length === 0 && outputsResults.rows.length === 0)
      return { pageResults: [], totalResultCount: 0 };

    const ids = uniq([
      ...inputsResults.rows.map(mapTxInModel).flatMap((input) => input.txInputId),
      ...outputsResults.rows.map((outputModel) => mapTxOutModel(outputModel)).flatMap((output) => output.txId)
    ]);

    return {
      pageResults: await this.transactionsByHashes({ ids: applyPagination(ids, pagination) }),
      totalResultCount: ids.length
    };
  }

  public async transactionsByHashes({ ids }: TransactionsByIdsArgs): Promise<Cardano.TxAlonzo[]> {
    if (ids.length > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `Transaction ids count of ${ids.length} can not be greater than ${this.#paginationPageSizeLimit}`
      );
    }

    const byteIds = ids.map((id) => hexStringToBuffer(id.toString()));
    this.#logger.debug('About to find transactions with hashes:', byteIds);
    const txResults: QueryResult<TxModel> = await this.db.query(Queries.findTransactionsByHashes, [byteIds]);
    if (txResults.rows.length === 0) return [];

    const [inputs, outputs, mints, withdrawals, redeemers, metadata, collaterals, certificates] = await Promise.all([
      this.#builder.queryTransactionInputsByHashes(ids),
      this.#builder.queryTransactionOutputsByHashes(ids),
      this.#builder.queryTxMintByHashes(ids),
      this.#builder.queryWithdrawalsByHashes(ids),
      this.#builder.queryRedeemersByHashes(ids),
      this.#metadataService.queryTxMetadataByHashes(ids),
      this.#builder.queryTransactionInputsByHashes(ids, true),
      this.#builder.queryCertificatesByHashes(ids)
    ]);

    return txResults.rows.map((tx) => {
      const txId = Cardano.TransactionId(tx.id.toString('hex'));
      const txInputs = orderBy(inputs.filter((input) => input.txInputId === txId).map(mapTxIn), ['index']);
      const txCollaterals = orderBy(collaterals.filter((col) => col.txInputId === txId).map(mapTxIn), ['index']);
      const txOutputs = orderBy(outputs.filter((output) => output.txId === txId).map(mapTxOut), ['index']);

      return mapTxAlonzo(tx, {
        certificates: certificates.get(txId),
        collaterals: txCollaterals,
        inputs: txInputs,
        metadata: metadata.get(txId),
        mint: mints.get(txId),
        outputs: txOutputs,
        redeemers: redeemers.get(txId),
        withdrawals: withdrawals.get(txId)
      });
    });
  }

  public async blocksByHashes({ ids }: BlocksByIdsArgs): Promise<Cardano.Block[]> {
    if (ids.length > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `Block ids count of ${ids.length} can not be greater than ${this.#paginationPageSizeLimit}`
      );
    }

    this.#logger.debug('About to find network tip');
    const tipResult: QueryResult<TipModel> = await this.db.query(Queries.findTip);
    const tip: TipModel = tipResult.rows[0];
    if (!tip) return [];

    const byteIds = ids.map((id) => hexStringToBuffer(id.toString()));
    this.#logger.debug('About to find blocks with hashes:', byteIds);
    const blocksResult: QueryResult<BlockModel> = await this.db.query(Queries.findBlocksByHashes, [byteIds]);
    if (blocksResult.rows.length === 0) return [];

    this.#logger.debug('About to find blocks outputs and fees for blocks:', byteIds);
    const outputResult: QueryResult<BlockOutputModel> = await this.db.query(Queries.findBlocksOutputByHashes, [
      byteIds
    ]);

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
