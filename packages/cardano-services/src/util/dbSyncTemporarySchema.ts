import { Logger } from 'ts-log';
import { Pool } from 'pg';

const getTemporarySchemaForDbSync = (epochLength = 432_000_000) =>
  `
CREATE TEMPORARY VIEW epoch_details AS (
  SELECT
    epoch_no,
    optimal_pool_count,
    CASE
      WHEN no = (SELECT MAX(no) FROM epoch)
        THEN EXTRACT(EPOCH FROM (end_time - start_time)) * 1000
      ELSE
        ${epochLength}
    END AS epoch_length
  FROM epoch
  JOIN epoch_param ON
    epoch_no = no
  ORDER BY no DESC
);

CREATE TEMPORARY VIEW current_epoch AS (
  SELECT *
  FROM epoch_details
  LIMIT 1
);

CREATE TEMPORARY VIEW blocks_created AS (
  SELECT
    COUNT(1) AS blocks_created,
    pool_hash_id
  FROM block
  JOIN slot_leader ON
    block.slot_leader_id = slot_leader.id
  GROUP BY pool_hash_id
);

CREATE TEMPORARY VIEW pools_delegates AS (
  SELECT
    pool_hash.id AS pool_hash_id,
    pu.reward_addr_id AS addr_id
  FROM pool_hash
  JOIN pool_update pu ON
    pu.id = (
      SELECT MAX(id)
      FROM pool_update pu2
      WHERE pu2.hash_id = pool_hash.id
    )
  LEFT JOIN pool_retire pr ON
    pr.id = (
      SELECT MAX(id)
      FROM pool_retire pr2
      WHERE pr2.hash_id = pool_hash.id
    )
  WHERE
    pr.id IS NULL OR pr.announced_tx_id < pu.registered_tx_id
);

CREATE TEMPORARY VIEW total_rewards_of_reward_acc AS (
  SELECT
    SUM(r.amount) AS amount,
    pd.pool_hash_id
  FROM reward r
  JOIN pools_delegates pd ON
    pd.addr_id = r.addr_id
  GROUP BY pd.pool_hash_id
);

CREATE TEMPORARY VIEW total_withdraws_of_reward_acc AS (
  SELECT
    SUM(w.amount) AS amount,
    pd.pool_hash_id
  FROM withdrawal w
  JOIN pools_delegates pd ON
    pd.addr_id = w.addr_id
  GROUP BY pd.pool_hash_id
);

CREATE TEMPORARY VIEW utxos AS (
  SELECT
    value,
    stake_address_id
  FROM tx_out
  LEFT JOIN tx_in ON
    tx_out.tx_id = tx_in.tx_out_id AND
    tx_out.index = tx_in.tx_out_index
  LEFT JOIN tx AS tx_in_tx ON
    tx_in_tx.id = tx_in.tx_in_id AND
    tx_in_tx.valid_contract = TRUE
  JOIN tx AS tx_out_tx ON
    tx_out_tx.id = tx_out.tx_id AND
    tx_out_tx.valid_contract = TRUE
  WHERE
    tx_in_tx.id IS NULL
);

CREATE TEMPORARY VIEW owners_total_utxos AS (
  SELECT
    SUM(value) AS amount,
    pu.hash_id
  FROM utxos
  JOIN pool_owner o ON
    o.addr_id = stake_address_id
  JOIN pool_update pu ON
    o.pool_update_id = pu.id
  GROUP BY pu.hash_id
);

CREATE TEMPORARY VIEW active_stake AS (
  SELECT
    SUM(es.amount) AS active_stake,
    es.pool_id AS pool_hash_id
  FROM epoch_stake es
  WHERE
    es.epoch_no = (SELECT epoch_no FROM current_epoch)
  GROUP BY es.pool_id
);

CREATE TEMPORARY VIEW pools_delegated AS (
SELECT
  ph.id,
  ph.view,
  pu.id AS update_id,
  pu.active_epoch_no,
  pu.pledge,
  sa.id AS stake_address_id
FROM pool_hash ph
JOIN pool_update pu ON
  pu.id = (
    SELECT id
    FROM pool_update pu2
    WHERE pu2.hash_id = ph.id
    ORDER BY id DESC
    LIMIT 1
  )
JOIN stake_address sa ON
  sa.id = pu.reward_addr_id
LEFT JOIN delegation d1 ON
  sa.id = d1.addr_id
WHERE
  NOT EXISTS (
    SELECT TRUE
    FROM delegation d2
    WHERE d2.addr_id = d1.addr_id
      AND d2.tx_id > d1.tx_id
  )
  AND NOT EXISTS (
    SELECT TRUE
    FROM stake_deregistration
    WHERE stake_deregistration.addr_id = d1.addr_id
      AND stake_deregistration.tx_id > d1.tx_id
  )
);

CREATE TEMPORARY VIEW pool_owner_rewards AS (
  SELECT
    COALESCE(SUM(r.amount), 0) AS total_amount,
    sa.id AS stake_address_id,
    r.pool_id
  FROM reward r
  JOIN stake_address sa ON
      sa.id = r.addr_id
  WHERE
    sa.id IN (SELECT stake_address_id FROM pools_delegated) AND
    r.spendable_epoch <= (SELECT epoch_no FROM current_epoch)
  GROUP BY r.pool_id, sa.id
);

CREATE TEMPORARY VIEW pool_owner_withdraws AS (
  SELECT
    COALESCE(SUM(w.amount), 0) AS total_amount,
    sa.id AS stake_address_id
  FROM withdrawal w
  JOIN tx ON
    tx.id = w.tx_id AND
    tx.valid_contract = TRUE
  JOIN stake_address sa ON
    sa.id = w.addr_id
  JOIN pools_delegated pool ON
    pool.stake_address_id = sa.id
  GROUP BY sa.id
);

CREATE TEMPORARY VIEW reward_acc_balance AS (
  SELECT
    r.total_amount - w.total_amount AS total_amount,
    r.stake_address_id,
    r.pool_id
  FROM pool_owner_rewards r
  JOIN pool_owner_withdraws w ON
    r.stake_address_id = w.stake_address_id
);

CREATE TEMPORARY VIEW owners_utxo AS (
  SELECT
    tx_out.value AS value,
    pu.hash_id
  FROM tx_out
  JOIN pool_owner o ON
    o.addr_id = tx_out.stake_address_id
  JOIN pool_update pu ON
    o.pool_update_id = pu.id
    AND pu.hash_id IN (SELECT id FROM pools_delegated)
  LEFT JOIN tx_in ON
    tx_out.tx_id = tx_in.tx_out_id AND
    tx_out.index::smallint = tx_in.tx_out_index::smallint
  LEFT JOIN tx AS tx_in_tx ON
    tx_in_tx.id = tx_in.tx_in_id AND
      tx_in_tx.valid_contract = TRUE
  JOIN tx AS tx_out_tx ON
    tx_out_tx.id = tx_out.tx_id AND
      tx_out_tx.valid_contract = TRUE
  WHERE
    tx_in_tx.id IS NULL
);

CREATE TEMPORARY VIEW owners_balance AS (
  SELECT
    SUM(value) AS total_amount,
    hash_id AS pool_hash_id
  FROM owners_utxo
  GROUP BY hash_id
);
`;

export const dumpDbSyncTemporarySchema = (epochLength?: number) =>
  process.stdout.write(getTemporarySchemaForDbSync(epochLength));

/**
 * Installs the cardano-services temporary schema on top of the db-sync schema
 *
 * @param db the pg.Pool connections on which to install the temporary schema
 * @param logger the ts-log.logger
 * @param epochLength the length of the epoch in milliseconds
 * @returns the pg.Pool connections pool itself
 */
export const installTemporarySchemaOnDbSync = (db: Pool, logger: Logger, epochLength?: number) => {
  db.on('connect', async (client) => {
    try {
      logger.debug('Installing temporay schema on db-sync for new client');

      await client.query(getTemporarySchemaForDbSync(epochLength));

      logger.info('Temporay schema for new client correctly installed on db-sync');
    } catch (error) {
      logger.error(error, 'while installing temporay schema on db-sync for new client');
    }
  });

  return db;
};
