import * as Queries from './queries';
import { BlockModel, BlockOutputModel, TipModel, TxInOutModel, TxModel } from './types';
import { Cardano, ChainHistoryProvider, TransactionsByAddressesArgs } from '@cardano-sdk/core';
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

    const hashes = uniq([
      ...inputsResults.rows.map(mapTxIn).flatMap((input) => input.txId),
      ...outputsResults.rows.map((output) => mapTxOut(output)).flatMap((output) => output.txId)
    ]);
    return this.transactionsByHashes(hashes);
  }

  public async transactionsByHashes(hashes: Cardano.TransactionId[]): Promise<Cardano.TxAlonzo[]> {
    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash.toString()));
    this.#logger.debug('About to find transactions with hashes:', byteHashes);
    const txResults: QueryResult<TxModel> = await this.db.query(Queries.findTransactionsByHashes, [byteHashes]);
    if (txResults.rows.length === 0) return [];
    const [inputs, outputs, mints, withdrawals, redeemers, metadata, collaterals, certificates] = await Promise.all([
      this.#builder.queryTransactionInputsByHashes(hashes),
      this.#builder.queryTransactionOutputsByHashes(hashes),
      this.#builder.queryTxMintByHashes(hashes),
      this.#builder.queryWithdrawalsByHashes(hashes),
      this.#builder.queryRedeemersByHashes(hashes),
      this.#metadataService.queryTxMetadataByHashes(hashes),
      this.#builder.queryTransactionInputsByHashes(hashes, true),
      this.#builder.queryCertificatesByHashes(hashes)
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

  public async blocksByHashes(hashes: Cardano.BlockId[]): Promise<Cardano.Block[]> {
    this.#logger.debug('About to find network tip');
    const tipResult: QueryResult<TipModel> = await this.db.query(Queries.findTip);
    const tip: TipModel = tipResult.rows[0];
    if (!tip) return [];

    const byteHashes = hashes.map((hash) => hexStringToBuffer(hash.toString()));
    this.#logger.debug('About to find blocks with hashes:', byteHashes);
    const blocksResult: QueryResult<BlockModel> = await this.db.query(Queries.findBlocksByHashes, [byteHashes]);
    if (blocksResult.rows.length === 0) return [];

    this.#logger.debug('About to find blocks outputs and fees for blocks:', byteHashes);
    const outputResult: QueryResult<BlockOutputModel> = await this.db.query(Queries.findBlocksOutputByHashes, [
      byteHashes
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
