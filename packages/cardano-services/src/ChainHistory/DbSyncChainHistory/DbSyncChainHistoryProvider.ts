import * as Queries from './queries';
import { BlockModel, BlockOutputModel, TipModel, TxInOutModel, TxModel } from './types';
import {
  BlocksByIdsArgs,
  Cardano,
  ChainHistoryProvider,
  TransactionsByAddressesArgs,
  TransactionsByIdsArgs
} from '@cardano-sdk/core';
import { ChainHistoryBuilder } from './ChainHistoryBuilder';
import { DbSyncProvider } from '../../DbSyncProvider';
import { Logger } from 'ts-log';
import { MetadataService } from '../../Metadata';
import { Pool, QueryResult } from 'pg';
import { hexStringToBuffer } from '@cardano-sdk/util';
import { mapBlock, mapTxAlonzo, mapTxIn, mapTxOut } from './mappers';
import orderBy from 'lodash/orderBy';
import uniq from 'lodash/uniq';

export class DbSyncChainHistoryProvider extends DbSyncProvider implements ChainHistoryProvider {
  #builder: ChainHistoryBuilder;
  #metadataService: MetadataService;
  #logger: Logger;

  constructor(db: Pool, metadataService: MetadataService, logger: Logger) {
    super(db);
    this.#builder = new ChainHistoryBuilder(db, logger);
    this.#logger = logger;
    this.#metadataService = metadataService;
  }

  public async transactionsByAddresses({
    addresses,
    sinceBlock
  }: TransactionsByAddressesArgs): Promise<Cardano.TxAlonzo[]> {
    this.#logger.debug(`About to find transactions of addresses ${addresses} since block ${sinceBlock ?? 0}`);
    const inputsResults: QueryResult<TxInOutModel> = await this.db.query(Queries.findTxInputsByAddresses, [
      addresses,
      sinceBlock ?? 0
    ]);
    const outputsResults: QueryResult<TxInOutModel> = await this.db.query(Queries.findTxOutputsByAddresses, [
      addresses,
      sinceBlock ?? 0
    ]);

    if (inputsResults.rows.length === 0 && outputsResults.rows.length === 0) return [];

    const ids = uniq([
      ...inputsResults.rows.map(mapTxIn).flatMap((input) => input.txId),
      ...outputsResults.rows.map((output) => mapTxOut(output)).flatMap((output) => output.txId)
    ]);
    return this.transactionsByHashes({ ids });
  }

  public async transactionsByHashes({ ids }: TransactionsByIdsArgs): Promise<Cardano.TxAlonzo[]> {
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
      const txInputs = orderBy(
        inputs.filter((input) => input.txId === txId),
        ['index']
      );
      const txOutputs = orderBy(
        outputs.filter((output) => output.txId === txId),
        ['index']
      );
      const txCollaterals = orderBy(
        collaterals.filter((col) => col.txId === txId),
        ['index']
      );
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
