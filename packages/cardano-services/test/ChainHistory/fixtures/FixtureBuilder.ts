import * as Queries from './queries';
import { Cardano } from '@cardano-sdk/core';
import { DB_MAX_SAFE_INTEGER } from '../../../src/ChainHistory/DbSyncChainHistory/queries';
import { Logger } from 'ts-log';
import { Pool, QueryResult } from 'pg';
import { Range, bufferToHexString } from '@cardano-sdk/util';

export enum TxWith {
  AuxiliaryData = 'auxiliaryData',
  PoolRetireCertificate = 'poolRetireCertificate',
  PoolUpdateCertificate = 'poolUpdateCertificate',
  StakeRegistrationCertificate = 'stakeRegistrationCertificate',
  StakeDeregistrationCertificate = 'stakeDeregistrationCertificate',
  DelegationCertificate = 'delegationCertificate',
  MirCertificate = 'mirCertificate',
  CollateralInput = 'collateralInput',
  Mint = 'mint',
  MultiAsset = 'multiAsset',
  Redeemer = 'redeemer',
  Withdrawal = 'withdrawal',
  CollateralOutput = 'collateralOutput',
  ScriptReference = 'scriptReference'
}

export type AddressesInBlockRange = {
  addresses: Set<Cardano.PaymentAddress>;
  blockRange: Range<Cardano.BlockNo>;
  txInRangeCount: number;
};

export class ChainHistoryFixtureBuilder {
  #db: Pool;
  #logger: Logger;

  constructor(db: Pool, logger: Logger) {
    this.#db = db;
    this.#logger = logger;
  }

  public async getAddressesWithSomeInBlockRange(
    desiredQty: number,
    blockRange: Range<Cardano.BlockNo>
  ): Promise<AddressesInBlockRange> {
    const lowerBound = blockRange?.lowerBound ?? 0;
    const upperBound = blockRange?.upperBound ?? DB_MAX_SAFE_INTEGER;
    const txIds = new Set<bigint>();
    const addressesInBlockRange = {
      addresses: new Set<Cardano.PaymentAddress>(),
      blockRange: { lowerBound: Cardano.BlockNo(DB_MAX_SAFE_INTEGER), upperBound: Cardano.BlockNo(0) },
      txInRangeCount: 0
    };

    this.#logger.debug(`About to find transactions of addresses since block ${lowerBound} and before ${upperBound}`);

    const results: QueryResult<{
      address: string;
      block_no: number;
      tx_id: bigint;
    }> = await this.#db.query(Queries.transactionInBlockRange, [lowerBound, upperBound]);

    if (results.rows.length === 0) throw new Error(`No transactions found in range [${lowerBound} -> ${upperBound}].`);

    // Collect ony the requested amount of addresses and drop the excess.
    for (const { address } of results.rows) {
      if (addressesInBlockRange.addresses.size >= desiredQty) break;

      addressesInBlockRange.addresses.add(address as unknown as Cardano.PaymentAddress);
    }

    if (results.rows.length < desiredQty) {
      this.#logger.warn(`${desiredQty} addresses desired, only ${results.rows.length} results found`);
    }

    for (const { address, block_no, tx_id } of results.rows) {
      if (addressesInBlockRange.addresses.has(address as unknown as Cardano.PaymentAddress)) {
        txIds.add(tx_id);
        addressesInBlockRange.blockRange.lowerBound = Cardano.BlockNo(
          Math.min(addressesInBlockRange.blockRange.lowerBound, block_no)
        );
        addressesInBlockRange.blockRange.upperBound = Cardano.BlockNo(
          Math.max(addressesInBlockRange.blockRange.upperBound, block_no)
        );
      }
    }

    addressesInBlockRange.txInRangeCount = txIds.size;

    return addressesInBlockRange;
  }

  public async getBlockHashes(desiredQty: number): Promise<Cardano.BlockId[]> {
    this.#logger.debug(`About to fetch up to the last ${desiredQty} blocks`);
    const result: QueryResult<{ hash: Buffer }> = await this.#db.query(Queries.latestBlockHashes, [desiredQty]);
    const resultsQty = result.rows.length;
    if (result.rows.length === 0) {
      throw new Error('No blocks found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} blocks desired, only ${resultsQty} results found`);
    }
    return result.rows.map(({ hash }) => bufferToHexString(hash) as unknown as Cardano.BlockId);
  }

  // eslint-disable-next-line sonarjs/cognitive-complexity,complexity
  public async getTxHashes(desiredQty: number, options?: { with?: TxWith[] }): Promise<Cardano.TransactionId[]> {
    this.#logger.debug(`About to fetch up to the last ${desiredQty} transactions`);

    let query = Queries.latestTxHashes;
    if (options?.with) {
      query = Queries.beginLatestTxHashes;

      if (options.with.includes(TxWith.MultiAsset)) query += Queries.latestTxHashesWithMultiAsset;
      if (options.with.includes(TxWith.AuxiliaryData)) query += Queries.latestTxHashesWithAuxiliaryData;
      if (options.with.includes(TxWith.Mint)) query += Queries.latestTxHashesWithMint;
      if (options.with.includes(TxWith.Redeemer)) query += Queries.latestTxHashesWithRedeemer;
      if (options.with.includes(TxWith.CollateralInput)) query += Queries.latestTxHashesWithCollateral;
      if (options.with.includes(TxWith.PoolRetireCertificate)) query += Queries.latestTxHashesWithPoolRetireCerts;
      if (options.with.includes(TxWith.PoolUpdateCertificate)) query += Queries.latestTxHashesWithPoolUpdateCerts;
      if (options.with.includes(TxWith.StakeRegistrationCertificate))
        query += Queries.latestTxHashesWithStakeRegistrationCerts;
      if (options.with.includes(TxWith.StakeDeregistrationCertificate))
        query += Queries.latestTxHashesWithStakeDeregistrationCerts;
      if (options.with.includes(TxWith.DelegationCertificate)) query += Queries.latestTxHashesWithDelegationCerts;
      if (options.with.includes(TxWith.MirCertificate)) query += Queries.latestTxHashesWithMirCerts;
      if (options.with.includes(TxWith.Withdrawal)) query += Queries.latestTxHashesWithWithdrawal;
      if (options.with.includes(TxWith.CollateralOutput)) query += Queries.latestTxHashesWithCollateralOutput;
      if (options.with.includes(TxWith.ScriptReference)) query += Queries.latestTxHashesWithScriptReference;

      query += Queries.endLatestTxHashes;
    }

    const result: QueryResult<{ tx_hash: Buffer }> = await this.#db.query(query, [desiredQty]);

    const resultsQty = result.rows.length;
    if (result.rows.length === 0) {
      throw new Error('No transactions found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} transactions desired, only ${resultsQty} results found`);
    }
    return result.rows.map(({ tx_hash }) => bufferToHexString(tx_hash) as unknown as Cardano.TransactionId);
  }

  public async getMultiAssetTxOutIds(desiredQty: number) {
    this.#logger.debug('About to fetch genesis multiasset tx out ids');
    const result: QueryResult<{ tx_out_id: string }> = await this.#db.query(Queries.findMultiAssetTxOut, [desiredQty]);
    return result.rows.map(({ tx_out_id }) => BigInt(tx_out_id));
  }

  public async getGenesisAddresses() {
    this.#logger.debug('About to fetch genesis addresses');
    const result: QueryResult<{ address: string }> = await this.#db.query(Queries.genesisUtxoAddresses);
    return result.rows.map(({ address }) => address as unknown as Cardano.PaymentAddress);
  }

  public async getDistinctAddresses(desiredQty: number): Promise<Cardano.PaymentAddress[]> {
    this.#logger.debug(`About to fetch up to the last ${desiredQty} distinct addresses`);
    const result: QueryResult<{ address: string }> = await this.#db.query(Queries.latestDistinctAddresses, [
      desiredQty
    ]);
    const resultsQty = result.rows.length;
    if (result.rows.length === 0) {
      throw new Error('No addresses found');
    } else if (resultsQty < desiredQty) {
      this.#logger.warn(`${desiredQty} distinct addresses desired, only ${resultsQty} results found`);
    }
    return result.rows.map(({ address }) => address as unknown as Cardano.PaymentAddress);
  }
}
