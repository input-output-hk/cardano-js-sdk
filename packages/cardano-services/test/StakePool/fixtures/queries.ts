export const subQueries = `
    WITH current_epoch AS (
    SELECT
      "no"
    FROM
      epoch
    ORDER BY
      no DESC
    LIMIT
      1
  ), pools_delegated AS (
    SELECT
      ph.id,
      ph.view,
      pu.id AS update_id,
      pu.active_epoch_no,
      pu.pledge,
      sa.id AS stake_address_id
    FROM
      pool_hash ph
      JOIN pool_update pu ON pu.id = (
        SELECT
          id
        FROM
          pool_update pu2
        WHERE
          pu2.hash_id = ph.id
        ORDER BY
          id DESC
        LIMIT
          1
      )
      JOIN stake_address sa ON sa.id = pu.reward_addr_id
      JOIN delegation d1 on sa.id = d1.addr_id
    WHERE
      NOT EXISTS (
        SELECT
          TRUE
        FROM
          delegation d2
        WHERE
          d2.addr_id = d1.addr_id
          AND d2.tx_id > d1.tx_id
      )
      AND NOT EXISTS (
        SELECT
          TRUE
        FROM
          stake_deregistration
        WHERE
          stake_deregistration.addr_id = d1.addr_id
          AND stake_deregistration.tx_id > d1.tx_id
      )
  ),
  pool_owner_rewards AS (
    SELECT
      COALESCE(SUM(r.amount), 0) AS total_amount,
      sa.id AS stake_address_id,
      r.pool_id
    FROM
      reward r
      JOIN stake_address sa ON sa.id = r.addr_id
    WHERE
      sa.id in (
        SELECT
          stake_address_id
        FROM
          pools_delegated
      )
      and r.spendable_epoch <= (
        SELECT
          "no"
        FROM
          current_epoch
      )
    GROUP BY
      r.pool_id,
      sa.id
  ),
  pool_owner_withdraws AS (
    SELECT
      COALESCE(SUM(w.amount), 0) AS total_amount,
      sa.id AS stake_address_id
    FROM
      withdrawal w
      JOIN tx ON tx.id = w.tx_id
      JOIN stake_address sa ON sa.id = w.addr_id
      JOIN pools_delegated pool on pool.stake_address_id = sa.id
    GROUP BY
      sa.id
  ),
  reward_acc_balance AS (
    SELECT
      (r.total_amount - w.total_amount) AS total_amount,
      r.stake_address_id,
      r.pool_id
    FROM
      pool_owner_rewards r
      JOIN pool_owner_withdraws w on r.stake_address_id = w.stake_address_id
  ),
  owners_utxo AS (
    SELECT
      tx_out.value AS value,
      pu.hash_id
    FROM
      tx_out
      JOIN pool_owner o ON o.addr_id = tx_out.stake_address_id
      JOIN pool_update pu ON o.pool_update_id = pu.id
      AND pu.hash_id IN (
        SELECT
          id
        FROM
          pools_delegated
      )
      LEFT JOIN tx_in ON tx_out.tx_id = tx_in.tx_out_id
      AND tx_out.index :: smallint = tx_in.tx_out_index :: smallint
      LEFT JOIN tx AS tx_in_tx ON tx_in_tx.id = tx_in.tx_in_id
      JOIN tx AS tx_out_tx ON tx_out_tx.id = tx_out.tx_id
    WHERE
      tx_in_tx.id IS NULL
  ),
  owners_balance AS (
    SELECT
      SUM(value) AS total_amount,
      hash_id AS pool_hash_id
    FROM
      owners_utxo
    GROUP BY
      hash_id
  )`;

export const beginFindPoolsWithMetadata = `
  SELECT
      ph.view AS pool_id,
      pod.json AS metadata,
      pool_hash_id as hash_id,
      pool_update.id as update_id
  FROM
    pools_delegated AS ph
    LEFT JOIN owners_balance o_balance ON ph.id = o_balance.pool_hash_id
    LEFT JOIN reward_acc_balance r_balance ON r_balance.pool_id = ph.id
    JOIN pool_update ON pool_update.hash_id = o_balance.pool_hash_id
    JOIN pool_metadata_ref metadata ON metadata.id = pool_update.meta_id
    JOIN off_chain_pool_data pod ON metadata.id = pod.pmr_id
    LEFT JOIN pool_retire pr ON pr.id = (
      SELECT
        id
      FROM
        pool_retire pr2
      WHERE
        pr2.hash_id = ph.id
      ORDER BY
        id desc
      LIMIT
        1
    )`;

export const beginFindPoolsWithoutMetadata = `
  SELECT
      ph.view AS pool_id,
      null AS metadata,
      pool_hash_id as hash_id,
      pool_update.id as update_id
  FROM
    pools_delegated AS ph
    LEFT JOIN owners_balance o_balance ON ph.id = o_balance.pool_hash_id
    LEFT JOIN reward_acc_balance r_balance ON r_balance.pool_id = ph.id
    JOIN pool_update ON pool_update.hash_id = o_balance.pool_hash_id
    LEFT JOIN pool_retire pr ON pr.id = (
      SELECT
        id
      FROM
        pool_retire pr2
      WHERE
        pr2.hash_id = ph.id
      ORDER BY
        id desc
      LIMIT
        1
    )`;

export const withPledgeMet = `
  WHERE
  (
    (
      COALESCE(o_balance.total_amount, 0) + COALESCE (r_balance.total_amount, 0)
    ) >= ph.pledge
  )
  AND`;

export const withPledgeNotMet = `
  WHERE
  (
    (
      COALESCE(o_balance.total_amount, 0) + COALESCE (r_balance.total_amount, 0)
    ) < ph.pledge
  )
  AND`;

export const withNoPledgeFilter = `
  WHERE
`;

export const withPoolActive = `
   (
    (
      ph.active_epoch_no <= (
        SELECT
          "no"
        FROM
          current_epoch
      )
      AND COALESCE(pr.retiring_epoch, 0) < ph.active_epoch_no
    )
  )`;

export const withPoolActivating = `
   (
    (
      ph.active_epoch_no > (
        SELECT
          "no"
        FROM
          current_epoch
      )
      AND COALESCE(pr.retiring_epoch, 0) <= ph.active_epoch_no
    )
  )`;

export const withPoolRetired = `
   (
    (
      COALESCE(pr.retiring_epoch, 0) <= (
        SELECT
          "no"
        FROM
          current_epoch
      )
      AND COALESCE(pr.retiring_epoch, 0) > ph.active_epoch_no
    )
  )`;

export const withPoolRetiring = `
   (
    (
      COALESCE(pr.retiring_epoch, 0) > (
        SELECT
          "no"
        FROM
          current_epoch
      )
      AND COALESCE(pr.retiring_epoch, 0) > ph.active_epoch_no
    )
  )`;

export const withNoStateFilter = `
  (
    true
  )`;

export const endFindPools = `
  LIMIT $1`;

export const beginPoolIds = `
  SELECT 
    ph.view AS pool_id
  FROM pool_update pu
  JOIN pool_hash ph ON 
    ph.id = pu.hash_id
  JOIN stake_address sa ON
    sa.id = pu.reward_addr_id
`;

export const withMetadata = `
  WHERE pu.hash_id IN (SELECT pool_id FROM pool_metadata_ref)
  GROUP BY pool_id
  ORDER BY pool_id ASC
  `;

export const withoutMetadata = `
  WHERE pu.hash_id NOT IN (SELECT pool_id FROM pool_metadata_ref)
  GROUP BY pool_id
  ORDER BY pool_id ASC
  `;

export const endPoolIds = `
  LIMIT $1
  `;

export const lastKnownEpoch = 'select no from epoch order by id desc limit 1';

const Queries = {
  beginFindPoolsWithMetadata,
  beginFindPoolsWithoutMetadata,
  beginPoolIds,
  endFindPools,
  endPoolIds,
  lastKnownEpoch,
  subQueries,
  withMetadata,
  withNoPledgeFilter,
  withPledgeMet,
  withPledgeNotMet,
  withPoolActivating,
  withPoolActive,
  withPoolRetired,
  withPoolRetiring,
  withoutMetadata
};

export default Queries;
