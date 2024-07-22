// cSpell:ignore cardano deleg deregistration drep unreg unregistration utxo utxos

import { Cardano, CardanoNode, CardanoNodeUtil } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { ProtocolParamsModel } from '../NetworkInfo/DbSyncNetworkInfoProvider/types';
import { partialTransactionsByIds, transactionsByIds } from './transactions';
import { toProtocolParams } from '../NetworkInfo/DbSyncNetworkInfoProvider/mappers';

// Workaround for @types/pg
declare module 'pg' {
  interface QueryConfig {
    rowMode?: 'array';
  }
}

export const getLovelaceSupply = async (db: Pool, maxLovelaceSupply: Cardano.Lovelace) => {
  const query = 'SELECT utxo + rewards AS circulating, reserves FROM ada_pots ORDER BY id DESC LIMIT 1';
  const { rows } = await db.query<{ circulating: string; reserves: string }>(query);
  const [row] = rows;

  // Workaround to make this work on epoch 0 as well.
  // Once db-sync will solve this problem the "no lines found" case can be removed.
  return row
    ? { circulating: BigInt(row.circulating), total: maxLovelaceSupply - BigInt(row.reserves) }
    : { circulating: 0n, total: maxLovelaceSupply };
};

// committee_term_limit min_committee_size
export const getProtocolParameters = async (db: Pool) => {
  const query = `\
SELECT epoch_param.*, cost_model.costs FROM epoch_param
  LEFT JOIN cost_model ON cost_model.id = epoch_param.cost_model_id
  ORDER BY epoch_no DESC NULLS LAST LIMIT 1`;
  const { rows } = await db.query<ProtocolParamsModel>(query);

  return toProtocolParams(rows[0]);
};

export const getStake = async (cardanoNode: CardanoNode, db: Pool) => {
  const [live, active] = await Promise.all([
    cardanoNode.stakeDistribution().then(CardanoNodeUtil.toLiveStake),
    (async () => {
      const { rows } = await db.query<{ stake: string }>(
        'SELECT COALESCE(SUM(amount), 0) AS stake FROM epoch_stake WHERE epoch_no = (SELECT MAX(no) FROM epoch) - 1'
      );

      return BigInt(rows[0].stake);
    })()
  ]);

  return { active, live };
};

interface TxsByAddressesOptions {
  action?: (txs?: Cardano.HydratedTx[], utxos?: Cardano.HydratedTx[]) => void;
  blockId?: string;
  lower?: Cardano.BlockNo;
}

export const transactionsByAddresses = async (
  addresses: Cardano.PaymentAddress[],
  db: Pool,
  options: TxsByAddressesOptions = {}
) => {
  const { action, blockId, lower } = options;

  // In case of last block, let's pick all the transactions from it (last block), next let's pick relevant inputs and outputs
  const fromLastBlock = async () => {
    const text = `\
WITH txs AS (SELECT tx.id AS tid FROM tx WHERE block_id = $1)
SELECT DISTINCT tid FROM (
  SELECT tid, address FROM txs JOIN tx_out ON tid = tx_id
  UNION ALL
  SELECT tid, address FROM txs JOIN tx_in ON tid = tx_in_id JOIN tx_out ON tx_out_id = tx_id AND tx_out_index = index
) t WHERE address = ANY($2)`;

    const result = await db.query<[string]>({ name: 'l_block', rowMode: 'array', text, values: [blockId, addresses] });
    return [result.rows.flat()] as const;
  };

  // In case of wallet restoration, let's just pick all the relevant inputs and outputs
  const walletRestore = async () => {
    const text = `\
WITH outputs AS (SELECT tx_id, index FROM tx_out WHERE address = ANY($1))
SELECT DISTINCT tid FROM (
  SELECT tx_id AS tid FROM outputs
  UNION ALL
  SELECT tx_in_id AS tid FROM outputs JOIN tx_in ON tx_out_id = tx_id AND tx_out_index = index
) t`;

    const result = await db.query<[string]>({ name: 'restore', rowMode: 'array', text, values: [addresses] });
    return [result.rows.flat()] as const;
  };

  // In case of wallet reconnection, ...
  const walletReConnection = async () => {
    // ... first of all let's convert the blockNo in block.id to save some JOINs, ...
    const text1 = 'SELECT id FROM block WHERE block_no = $1';
    const result1 = await db.query<[string]>({ name: 'n2d', rowMode: 'array', text: text1, values: [lower] });
    const [bId] = result1.rows[0];

    // ... next let's pick all the relevant transactions from latest blocks and from them, relevant inputs and outputs;
    const text2 = `\
WITH txs AS (SELECT tx.id AS tid FROM tx WHERE block_id >= $1)
SELECT DISTINCT tid FROM (
  SELECT tid, address FROM txs JOIN tx_out ON tid = tx_id
  UNION ALL
  SELECT tid, address FROM txs JOIN tx_in ON tid = tx_in_id JOIN tx_out ON tx_out_id = tx_id AND tx_out_index = index
) t WHERE address = ANY($2)`;

    // ... last let's pick not spent relevant outputs from previous blocks
    const text3 = `\
WITH source AS (SELECT tx_id, tx_in_id FROM tx_out JOIN tx ON tx_id = tx.id AND block_id < $1
  LEFT JOIN tx_in ON tx_out_id = tx_id AND tx_out_index = index
  WHERE address = ANY($2)),
unspent AS (SELECT tx_id FROM source WHERE tx_in_id IS NULL)
SELECT DISTINCT tx_id FROM (
  SELECT tx_id FROM unspent
  UNION ALL
  SELECT tx_in_id AS tx_id FROM source WHERE tx_in_id > (SELECT MIN(tx_id) FROM unspent)
) t`;

    const [result2, result3] = await Promise.all([
      db.query<[string]>({ name: 'reconnect2', rowMode: 'array', text: text2, values: [bId, addresses] }),
      db.query<[string]>({ name: 'reconnect3', rowMode: 'array', text: text3, values: [bId, addresses] })
    ]);

    return [result2.rows.flat(), result3.rows.flat()] as const;
  };

  const [txIds, partialTxIds] = await (blockId ? fromLastBlock() : lower ? walletReConnection() : walletRestore());

  if (txIds.length === 0 && (!partialTxIds || partialTxIds.length === 0)) return [];

  const chunks: Cardano.HydratedTx[][] = [];

  for (let i = 0; i < txIds.length; i += 100) {
    const txs = await transactionsByIds(txIds.slice(i, i + 100), db);

    action ? action(txs) : chunks.push(txs);
  }

  if (partialTxIds)
    for (let i = 0; i < partialTxIds.length; i += 100)
      action!(undefined, await partialTransactionsByIds(partialTxIds.slice(i, i + 100), db));

  return chunks.flat();
};
