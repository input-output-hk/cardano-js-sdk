/* eslint-disable sonarjs/no-nested-template-literals */
import { Cardano, MultipleChoiceSearchFilter, StakePoolQueryOptions } from '@cardano-sdk/core';
import { OrderByOptions, SubQuery } from './types';
import { getStakePoolSortType } from './util';

export const findLastEpoch = `
 SELECT 
  "no"
 FROM epoch
 ORDER BY no DESC 
 LIMIT 1
`;

export const findTotalAda = `
SELECT COALESCE(SUM(value)) AS total_ada
FROM tx_out AS tx_outer WHERE
NOT exists
  ( SELECT tx_out.id
  FROM tx_out
  JOIN tx_in on
  tx_out.tx_id = tx_in.tx_out_id AND
  tx_out.index = tx_in.tx_out_index
  WHERE tx_outer.id = tx_out.id
  );
`;

export const findPoolsMetrics = `
with current_epoch AS (
  SELECT
    e."no" AS epoch_no,
    optimal_pool_count 
  FROM epoch e
  JOIN epoch_param ep on 
    ep.epoch_no = e."no"
  order by e.no desc limit 1
),
blocks_created AS (
  SELECT 
    count(1) AS blocks_created,
    pool_hash.id AS pool_hash_id
  FROM block 
    JOIN slot_leader on block.slot_leader_id = slot_leader.id
    JOIN pool_hash on slot_leader.pool_hash_id = pool_hash.id
  where pool_hash.id = ANY($1)
  GROUP BY pool_hash.id
),
pools_delegates AS (
  SELECT 
    ph.id AS pool_hash_id,
    sa.id AS addr_id
  FROM pool_hash ph 
  JOIN pool_update pu
        ON pu.id = (
          SELECT id
          FROM pool_update pu2
          WHERE pu2.hash_id = ph.id
          ORDER BY id DESC
          LIMIT 1
        )
   LEFT JOIN pool_retire pr 
          ON pr.id = (
            SELECT id
            FROM pool_retire pr2
            WHERE pr2.hash_id = ph.id
            ORDER BY id desc 
            LIMIT 1
      )
   JOIN stake_address sa ON 
     sa.hash_raw  = pu.reward_addr 
   WHERE (pr.id is null or pr.announced_tx_id < pu.registered_tx_id) and
       ph.id = ANY($1)
  ),
  total_rewards_of_reward_acc AS (
    SELECT 
      SUM(r.amount) AS amount,
      pd.pool_hash_id
    FROM reward r
    JOIN pools_delegates pd ON 
      pd.addr_id = r.addr_id
    GROUP BY pd.pool_hash_id
  ),
  total_withdraws_of_reward_acc AS (
    SELECT 
      SUM(w.amount) AS amount,
      pd.pool_hash_id
    FROM withdrawal w
    JOIN pools_delegates pd ON 
      pd.addr_id = w.addr_id 
    GROUP BY pd.pool_hash_id
  ),
  owners_total_utxos AS (
    SELECT
      sum(tx_out.value) AS amount,
      o.pool_hash_id 
    FROM tx_out
    JOIN pool_owner o on 
      o.addr_id = tx_out.stake_address_id and 
      o.pool_hash_id = ANY($1)
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
      tx_in_tx.id IS null
    GROUP BY o.pool_hash_id 
  ),
active_stake AS (
SELECT 
  sum(es.amount) AS active_stake,
  es.pool_id  AS pool_hash_id
FROM epoch_stake es
where es.pool_id = ANY($1) 
  AND es.epoch_no = (SELECT epoch_no FROM current_epoch)
GROUP BY es.pool_id 
),
active_delegations AS (
  SELECT 
    d1.addr_id,
    ph.id AS pool_hash_id
  FROM pool_hash ph
  JOIN delegation d1 on
    ph.id = d1.pool_hash_id 
  WHERE ph.id = ANY($1)
   AND NOT EXISTS
     (SELECT TRUE
      FROM delegation d2
      WHERE d2.addr_id=d1.addr_id 
        AND d2.tx_id>d1.tx_id)
   AND NOT EXISTS
     (SELECT TRUE
      FROM stake_deregistration
      WHERE stake_deregistration.addr_id=d1.addr_id
        AND stake_deregistration.tx_id>d1.tx_id)
),
delegators AS (
  SELECT
    COUNT(1) AS delegators,
    d.pool_hash_id 
  FROM active_delegations d 
  GROUP BY d.pool_hash_id  
),
total_utxos AS (
  SELECT 
    COALESCE(SUM(tx_out.value),0) AS total_amount,
    ad.pool_hash_id
  FROM active_delegations ad 
  JOIN tx_out ON 
    tx_out.stake_address_id = ad.addr_id
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
  GROUP BY ad.pool_hash_id
),
total_rewards AS (
  SELECT 
    COALESCE(SUM(r.amount),0) AS total_amount,
    ad.pool_hash_id
    FROM active_delegations ad 
    JOIN reward r ON 
        ad.addr_id = r.addr_id
    WHERE r.spendable_epoch <= (SELECT epoch_no FROM current_epoch)
    GROUP BY ad.pool_hash_id
),
total_withdraws AS (
  SELECT 
    COALESCE(SUM(w.amount),0) AS total_amount,
    ad.pool_hash_id
    FROM withdrawal w
    JOIN tx ON tx.id = w.tx_id AND 
      tx.valid_contract = TRUE
    JOIN active_delegations ad ON ad.addr_id = w.addr_id
    GROUP BY ad.pool_hash_id
),
live_stake AS (
  SELECT 
    (total_utxos.total_amount +
    COALESCE(tr.total_amount,0) -
    COALESCE(tw.total_amount,0)) AS live_stake,
    total_utxos.pool_hash_id
  FROM total_utxos
  LEFT JOIN total_rewards tr on
    total_utxos.pool_hash_id = tr.pool_hash_id
  LEFT JOIN total_withdraws tw on 
    total_utxos.pool_hash_id = tw.pool_hash_id
)
SELECT 
 COALESCE(bc.blocks_created,0) AS blocks_created,
 COALESCE(d.delegators,0) AS delegators,
 COALESCE(a_stake.active_stake,0) AS active_stake,
 COALESCE(l_stake.live_stake,0) AS live_stake,
 (COALESCE(tr.amount,0) - COALESCE(tw.amount,0) + COALESCE (otu.amount,0))
 AS live_pledge,
 CASE
    WHEN $2::numeric = 0::numeric 
    THEN 0::numeric
    ELSE 
      (
        (COALESCE(a_stake.active_stake,0::numeric) + COALESCE(l_stake.live_stake,0::numeric)) * 
        ((SELECT optimal_pool_count FROM current_epoch)::NUMERIC) /
        ($2::numeric)
      )::numeric
  END AS saturation,
  CASE
    WHEN (COALESCE(a_stake.active_stake,0)+COALESCE(l_stake.live_stake,0))::numeric = 0::numeric
    THEN 0::numeric
    ELSE
    (COALESCE(a_stake.active_stake,0)/(COALESCE(a_stake.active_stake,0)+COALESCE(l_stake.live_stake,0))) 
  END AS active_stake_percentage,
  CASE
  WHEN (COALESCE(a_stake.active_stake,0)+COALESCE(l_stake.live_stake,0))::numeric = 0::numeric
  THEN 0::numeric
  ELSE
  (COALESCE(l_stake.live_stake,0)/(COALESCE(a_stake.active_stake,0)+COALESCE(l_stake.live_stake,0))) 
  END AS live_stake_percentage,
  ph.id AS pool_hash_id 
FROM pool_hash ph
LEFT JOIN blocks_created bc on 
  bc.pool_hash_id = ph.id
LEFT JOIN delegators d on 
  d.pool_hash_id = ph.id
LEFT JOIN active_stake a_stake on 
  a_stake.pool_hash_id = ph.id
LEFT JOIN live_stake l_stake on 
  l_stake.pool_hash_id = ph.id
LEFT JOIN total_rewards_of_reward_acc AS tr ON
	tr.pool_hash_id = ph.id
LEFT JOIN total_withdraws_of_reward_acc AS tw ON
	tw.pool_hash_id = ph.id
LEFT JOIN owners_total_utxos otu on 
	otu.pool_hash_id = ph.id
where id = ANY($1)
`;

const epochRewardsSubqueries = (limit?: number) => `
WITH epochs AS (
	SELECT 
	  "no" AS epoch_no,
		(extract(epoch FROM (end_time - start_time)) * 1000) AS epoch_length
	FROM epoch
	ORDER BY no DESC
  ${limit !== undefined ? `LIMIT ${limit}` : ''}
),
pool_rewards_per_epoch AS (
	SELECT
		reward.pool_id AS hash_id,
		epochs.epoch_no,
		SUM(reward.amount) AS total_amount
	FROM epochs
	JOIN reward 
		ON reward.earned_epoch = epochs.epoch_no
		AND reward.pool_id = ANY($1)
  WHERE reward.type = 'member'
	GROUP BY reward.pool_id, epochs.epoch_no
),
pool_stake_per_epoch AS (
	SELECT
		epoch_stake.pool_id AS hash_id,
		epochs.epoch_no,
    SUM(epoch_stake.amount) AS active_stake
	FROM epochs
	JOIN epoch_stake 
		ON epoch_stake.epoch_no = epochs.epoch_no
		AND epoch_stake.pool_id = ANY($1)
	GROUP BY epoch_stake.pool_id, epochs.epoch_no
),
epoch_rewards AS (
	SELECT 
		epochs.epoch_no,
		epochs.epoch_length,
		stake.hash_id,
		COALESCE(rewards.total_amount, 0) AS total_rewards,
		COALESCE(stake.active_stake, 0) AS active_stake,		
		CASE 
			WHEN pool.fixed_cost >= rewards.total_amount
	    	THEN COALESCE(rewards.total_amount, 0)
	    	ELSE (
	      	COALESCE(
	      		FLOOR((rewards.total_amount - pool.fixed_cost) * pool.margin) + pool.fixed_cost
	      	, 0)
	    	) 
		END AS operator_fees,
		CASE 
			WHEN COALESCE(stake.active_stake, 0) = 0
				THEN 0
			WHEN pool.fixed_cost >= rewards.total_amount
		    THEN (
		      COALESCE(
		      	(rewards.total_amount - COALESCE(rewards.total_amount, 0)) / stake.active_stake
		      , 0)
		    )
		    ELSE (
		      COALESCE(
						(rewards.total_amount - 
							COALESCE(
	      				FLOOR((rewards.total_amount - pool.fixed_cost) * pool.margin) + pool.fixed_cost
	      			, 0)) / stake.active_stake
		      , 0)
		    ) END AS member_roi
  FROM pool_stake_per_epoch AS stake 
  JOIN epochs 
  	ON epochs.epoch_no = stake.epoch_no
  LEFT JOIN pool_rewards_per_epoch AS rewards
  	ON rewards.epoch_no = stake.epoch_no
  	AND rewards.hash_id = stake.hash_id
  JOIN pool_update AS pool
    ON pool.id = (
      SELECT id
      FROM pool_update
      WHERE hash_id = stake.hash_id 
        AND active_epoch_no <= epochs.epoch_no
      ORDER BY id DESC
      LIMIT 1
    )
)`;

export const findPoolEpochRewards = (limit?: number) => `
  ${epochRewardsSubqueries(limit)}
  SELECT 
    epoch_no,
    epoch_length::TEXT,
    hash_id,
    total_rewards,
    active_stake,
    operator_fees,
    member_roi
  FROM epoch_rewards
  ORDER BY epoch_no desc
`;

export const findPoolAPY = (limit?: number) => `
  ${epochRewardsSubqueries(limit)},
  avg_daily_roi AS (
    SELECT 
      hash_id,
      SUM(member_roi / (epoch_length / 86400000)) / count(1) AS avg_roi
    FROM epoch_rewards
    GROUP BY hash_id
  ),
  pool_apy AS (
    SELECT 
      epochs.hash_id,
      POWER(
        1 + (avg_daily_roi.avg_roi * (epochs.epoch_length / 86400000)), 
        365 / (epochs.epoch_length / 86400000)
      ) - 1 AS apy
    FROM epoch_rewards AS epochs
    JOIN (
      SELECT
        hash_id,
        MAX(epoch_no) AS epoch_no
        FROM epoch_rewards AS sub
        GROUP BY hash_id
      ) AS max_epoch 
      ON max_epoch.epoch_no = epochs.epoch_no 
      AND max_epoch.hash_id = epochs.hash_id
    JOIN avg_daily_roi
      ON avg_daily_roi.hash_id = epochs.hash_id
  )
  SELECT * FROM pool_apy
`;

export const findPools = `
SELECT 
  ph.id,
  pu.id AS update_id
FROM pool_hash ph
JOIN pool_update pu
  ON pu.id = (
    SELECT id
    FROM pool_update pu2
    WHERE pu2.hash_id = ph.id
    ORDER BY id DESC
    LIMIT 1
  )
`;

export const findPoolsRelays = `
SELECT
  hash_id,
  update_id,
  ipv4,
  ipv6,
  port,
  dns_name,
  dns_srv_name AS hostname --fixme: check this is correct
FROM pool_relay
JOIN pool_update 
  ON pool_relay.update_id = pool_update.id
WHERE update_id = ANY($1)
`;

export const findPoolsOwners = `
SELECT 
  stake.view AS address,
  owner.pool_hash_id AS hash_id
FROM pool_owner owner
JOIN pool_update 
    ON pool_update.registered_tx_id = owner.registered_tx_id
JOIN stake_address stake
  ON stake.id = owner.addr_id
WHERE pool_update.id = ANY($1)
`;

export const findPoolsRegistrations = `
SELECT  
  tx.hash AS tx_hash,
  pu.hash_id AS hash_id,
  active_epoch_no
FROM pool_update pu
JOIN tx
  ON tx.id = pu.registered_tx_id
WHERE pu.hash_id = ANY($1)
ORDER BY pu.id DESC
`;

export const findPoolsRetirements = `
SELECT  
  tx.hash AS tx_hash,
  pr.hash_id AS hash_id,
  retiring_epoch
FROM pool_retire pr
JOIN tx
  ON tx.id = pr.announced_tx_id
WHERE pr.hash_id = ANY($1)
`;

export const poolsByPledgeMetSubqueries: readonly SubQuery[] = [
  {
    id: { name: 'pools_delegated' },
    query: `
    SELECT 
      ph.id,
      ph.view,
      pu.id AS update_id,
      pu.active_epoch_no,
      pu.pledge,
      sa.id AS stake_address_id
    FROM pool_hash ph 
    JOIN pool_update pu
      ON pu.id = (
        SELECT id
        FROM pool_update pu2
        WHERE pu2.hash_id = ph.id
        ORDER BY id DESC
        LIMIT 1
      ) 
    JOIN stake_address sa ON
      sa.hash_raw = pu.reward_addr 
    JOIN delegation d1 on
      sa.id = d1.addr_id 
    WHERE NOT EXISTS
      (SELECT TRUE
        FROM delegation d2
        WHERE d2.addr_id=d1.addr_id 
          AND d2.tx_id>d1.tx_id)
    AND NOT EXISTS
      (SELECT TRUE
        FROM stake_deregistration
        WHERE stake_deregistration.addr_id=d1.addr_id
          AND stake_deregistration.tx_id>d1.tx_id)
    `
  },
  {
    id: { name: 'pool_owner_rewards' },
    query: `
  SELECT 
    COALESCE(SUM(r.amount),0) AS total_amount,
    sa.id AS stake_address_id,
    r.pool_id
  FROM reward r
  JOIN stake_address sa ON 
      sa.id = r.addr_id
  WHERE sa.id in (SELECT stake_address_id FROM pools_delegated) and
    r.spendable_epoch <= (SELECT "no" FROM current_epoch)
  GROUP BY r.pool_id, sa.id`
  },
  {
    id: { name: 'pool_owner_withdraws' },
    query: ` 
  SELECT 
    COALESCE(SUM(w.amount),0)  AS total_amount,
    sa.id AS stake_address_id
  FROM withdrawal w
  JOIN tx ON tx.id = w.tx_id AND 
    tx.valid_contract = TRUE
  JOIN stake_address sa ON sa.id = w.addr_id
  JOIN pools_delegated pool on pool.stake_address_id = sa.id 
  GROUP BY sa.id`
  },
  {
    id: { name: 'reward_acc_balance' },
    query: `
  SELECT 
    (r.total_amount - w.total_amount)  AS total_amount,
    r.stake_address_id,
    r.pool_id 
  FROM pool_owner_rewards r
  JOIN pool_owner_withdraws w 
    on r.stake_address_id = w.stake_address_id `
  },
  {
    id: { name: 'owners_utxo' },
    query: `
  SELECT
    tx_out.value AS value,
    o.pool_hash_id 
  FROM tx_out
  JOIN pool_owner o on 
    o.addr_id = tx_out.stake_address_id and 
    o.pool_hash_id in (SELECT id FROM pools_delegated)
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
    tx_in_tx.id IS NULL`
  },
  {
    id: { name: 'owners_balance' },
    query: `
  SELECT 
    SUM(value) AS total_amount,
    pool_hash_id
  FROM owners_utxo 
  GROUP BY pool_hash_id`
  }
];

export const POOLS_WITH_PLEDGE_MET = {
  JOIN_CLAUSE: `
    LEFT JOIN owners_balance o_balance ON 
        ph.id = o_balance.pool_hash_id
    LEFT JOIN reward_acc_balance r_balance ON
        r_balance.pool_id = ph.id`,
  SELECT_CLAUSE: `
    SELECT
        ph.id,
        ph.update_id
    FROM pools_delegated AS ph`,
  WHERE_CLAUSE: (metPledge: boolean) => ` 
    ((COALESCE(o_balance.total_amount,0) +
    COALESCE (r_balance.total_amount, 0)) 
    ${metPledge ? ' >=' : '<'} ph.pledge)`,
  WITH_CLAUSE: `WITH 
    current_epoch AS (${findLastEpoch}),
     ${poolsByPledgeMetSubqueries.map((subQuery) => `${subQuery.id.name} AS (${subQuery.query})`).join(', ')}
      `
};

export const findPoolsWithPledgeMet = (metPledge: boolean) => `
  ${POOLS_WITH_PLEDGE_MET.WITH_CLAUSE} 
  ${POOLS_WITH_PLEDGE_MET.SELECT_CLAUSE} 
  ${POOLS_WITH_PLEDGE_MET.JOIN_CLAUSE} 
  WHERE ${POOLS_WITH_PLEDGE_MET.WHERE_CLAUSE(metPledge)}`;

export const STATUS_QUERY = {
  SELECT_CLAUSE: `
    SELECT
      ph.id,
      pu.id AS update_id
    FROM pool_hash ph
    JOIN pool_update pu
        ON pu.id = (
          SELECT id
          FROM pool_update pu2
          WHERE pu2.hash_id = ph.id
          ORDER BY id DESC
          LIMIT 1
        )
    LEFT JOIN pool_retire pr 
        ON pr.id = (
          SELECT id
          FROM pool_retire pr2
          WHERE pr2.hash_id = ph.id
          ORDER BY id desc 
          LIMIT 1
    )
  `,
  WITH_CLAUSE: `WITH 
  current_epoch AS (${findLastEpoch})`
};

export const IDENTIFIER_QUERY = {
  JOIN_CLAUSE: {
    OFFLINE_METADATA: ` 
    LEFT JOIN pool_offline_data pod 
      ON pod.pool_id = ph.id
    `,
    POOL_UPDATE: ` 
    JOIN pool_update pu
      ON pu.id = (
        SELECT id
        FROM pool_update pu2
        WHERE pu2.hash_id = ph.id
        ORDER BY id DESC
        LIMIT 1
      )`
  },
  SELECT_CLAUSE: `
  SELECT 
    ph.id,
    pu.id AS update_id
  FROM pool_hash ph 
  `
};

export const getIdentifierFullJoinClause = () => `
${IDENTIFIER_QUERY.JOIN_CLAUSE.POOL_UPDATE} 
${IDENTIFIER_QUERY.JOIN_CLAUSE.OFFLINE_METADATA}`;

export const findPoolsData = `
SELECT 
  pu.hash_id,
  ph.hash_raw AS pool_hash,
  pu.id AS update_id,
  ph.view AS pool_id,
  sa.view AS reward_address,
  pu.reward_addr,
  pu.pledge,
  pu.fixed_cost,
  pu.margin,
  pu.vrf_key_hash,
  metadata.url AS metadata_url, 
  metadata.hash AS metadata_hash,
  pod.json AS offline_data,
  pod.json -> 'name' AS name
FROM pool_update pu
JOIN pool_hash ph ON 
  ph.id = pu.hash_id
JOIN stake_address sa ON
  sa.hash_raw = pu.reward_addr
LEFT JOIN pool_metadata_ref metadata
  ON metadata.id = pu.meta_id
LEFT JOIN pool_offline_data pod
  ON metadata.id = pod.pmr_id
WHERE pu.id = ANY($1)
`;

const toSimilarToString = (_array: string[]) => `%(${_array.join('|')})%`;

export const getIdentifierWhereClause = (
  identifier: MultipleChoiceSearchFilter<
    Partial<Pick<Cardano.PoolParameters, 'id'> & Pick<Cardano.StakePoolMetadata, 'name' | 'ticker'>>
  >
) => {
  const condition = ` ${identifier._condition} ` || ' or ';
  const names = [];
  const tickers = [];
  const ids = [];
  for (const value of identifier.values) {
    value.id && ids.push(value.id.toString());
    value.ticker && tickers.push(value.ticker);
    value.name && names.push(value.name);
  }
  const whereConditions = [];
  const params = [];
  if (names.length > 0) {
    params.push(toSimilarToString(names));
    // eslint-disable-next-line quotes
    whereConditions.push(`(pod."json" ->>'name')::varchar SIMILAR TO $1`);
  }
  if (tickers.length > 0) {
    params.push(toSimilarToString(tickers));
    whereConditions.push(`pod.ticker_name SIMILAR TO $${params.length}`);
  }
  if (ids.length > 0) {
    params.push(toSimilarToString(ids));
    whereConditions.push(`ph.view SIMILAR TO $${params.length}`);
  }
  return { params, where: `(${whereConditions.join(condition)})` };
};

export const getStatusWhereClause = (
  status: Cardano.StakePoolStatus[],
  columns?: {
    activeEpoch?: string;
  }
) => {
  const whereClause = [];
  const activeEpochColumn = columns?.activeEpoch || 'pu.active_epoch_no';
  if (status.includes(Cardano.StakePoolStatus.Retiring))
    whereClause.push(
      `(COALESCE(pr.retiring_epoch,0) > (SELECT "no" FROM current_epoch) 
          AND COALESCE(pr.retiring_epoch,0) > ${activeEpochColumn})`
    );
  if (status.includes(Cardano.StakePoolStatus.Retired))
    whereClause.push(
      `(COALESCE(pr.retiring_epoch,0) <= (SELECT "no" FROM current_epoch) 
          AND COALESCE(pr.retiring_epoch,0) > ${activeEpochColumn})`
    );
  if (status.includes(Cardano.StakePoolStatus.Activating))
    whereClause.push(
      `(${activeEpochColumn} > (SELECT "no" FROM current_epoch) 
          AND COALESCE(pr.retiring_epoch,0) <= ${activeEpochColumn})`
    );
  if (status.includes(Cardano.StakePoolStatus.Active))
    whereClause.push(
      `(${activeEpochColumn} <= (SELECT "no" FROM current_epoch) 
          AND COALESCE(pr.retiring_epoch,0) < ${activeEpochColumn})`
    );
  return `(${whereClause.join(' OR ')})`;
};

export const withPagination = (query: string, pagination?: StakePoolQueryOptions['pagination']) => {
  if (pagination) return `${query} LIMIT ${pagination.limit} OFFSET ${pagination.startAt} `;
  return query;
};

const orderBy = (query: string, sort: OrderByOptions[]) =>
  sort && sort.length > 0
    ? `${query} ORDER BY ${sort.map(({ field, order }) => `${field} ${order} NULLS LAST`).join(', ')}`
    : query;

export const addSentenceToQuery = (query: string, sentence: string) => query + sentence;

export const buildOrQueryFromClauses = (clauses: SubQuery[]) => {
  const uniqueIds = new Set();
  const uniqueClauses = clauses.filter((clause) => {
    const isDuplicate = uniqueIds.has(clause.id);
    uniqueIds.add(clause.id);
    if (!isDuplicate) {
      return true;
    }
  });
  const primarySubQueries = clauses.filter((clause) => clause.id.isPrimary);
  return `
    WITH ${uniqueClauses.map(({ id, query }) => `${id.name} AS (${query})`).join(', ')} 
    SELECT id, update_id
    FROM
    (${primarySubQueries.map((subQuery) => `SELECT id, update_id FROM ${subQuery.id.name}`).join(' UNION ')})
    AS pools
    GROUP BY id,update_id
    ORDER BY id DESC
    `;
};

export const getTotalCountQueryFromQuery = (query: string) => `
SELECT 
  COUNT(1) AS total_count
FROM (${query}) as query
`;

export const findPoolStats = `
WITH current_epoch AS (
	SELECT max(epoch_no) AS epoch_no 
	FROM block
),
last_pool_update AS (
	SELECT 
		pool_update.hash_id,
		pool_update.registered_tx_id,
		pool_update.active_epoch_no
	FROM pool_update 
	JOIN (
		SELECT hash_id, max(registered_tx_id) AS tx_id
		FROM pool_update
		WHERE active_epoch_no <= (SELECT epoch_no FROM current_epoch)
		GROUP BY hash_id
	) AS last_update ON pool_update.hash_id = last_update.hash_id 
	AND pool_update.registered_tx_id = last_update.tx_id
),
last_pool_retire AS (
	SELECT 
		pool_retire.hash_id, 
		max(pool_retire.announced_tx_id) AS announced_tx_id, 
		pool_retire.retiring_epoch FROM pool_retire 
	JOIN (
		SELECT hash_id, max(retiring_epoch) AS epoch
		FROM pool_retire
		GROUP BY hash_id
	) AS last_retired ON pool_retire.hash_id = last_retired.hash_id 
	AND pool_retire.retiring_epoch = last_retired.epoch
	GROUP BY pool_retire.hash_id, pool_retire.retiring_epoch
)
SELECT 
	count(
		CASE WHEN pool_retire.hash_id IS NULL
			OR (
				pool_update.active_epoch_no > pool_retire.retiring_epoch
				AND pool_retire.retiring_epoch <= (SELECT epoch_no FROM current_epoch)
			) THEN 1 ELSE NULL END) AS active,
	count(
		CASE WHEN pool_retire.hash_id IS NOT NULL
			AND (
				pool_update.active_epoch_no <= pool_retire.retiring_epoch
				AND pool_retire.retiring_epoch <= (SELECT epoch_no FROM current_epoch)
			) THEN 1 ELSE NULL END) AS retired,
	count(
		CASE WHEN pool_retire.hash_id IS NOT NULL
			AND (
				pool_update.active_epoch_no <= pool_retire.retiring_epoch
				AND pool_retire.retiring_epoch > (SELECT epoch_no FROM current_epoch)
			) THEN 1 ELSE NULL END) AS retiring
FROM last_pool_update AS pool_update 
LEFT JOIN last_pool_retire AS pool_retire 
	ON pool_update.hash_id = pool_retire.hash_id`;

const sortFieldMapping: Record<string, { field: string; secondary?: string[] }> = {
  cost: { field: 'fixed_cost', secondary: ['margin'] },
  name: { field: "lower((pod.json -> 'name')::TEXT)" }
};

const mapSort = (sort: OrderByOptions | undefined) => {
  if (!sort) return [];
  const mapping = sortFieldMapping[sort.field];
  if (!mapping) return [{ field: sort.field, order: sort.order }];
  const secondarySorts = mapping.secondary?.map((field) => ({ field, order: sort.order })) ?? [];
  return [{ field: mapping.field, order: sort.order }, ...secondarySorts];
};

export const withSort = (query: string, sort?: StakePoolQueryOptions['sort'], defaultSort?: OrderByOptions[]) => {
  if (!sort?.field && defaultSort) {
    const defaultMappedSort = defaultSort.flatMap(mapSort);
    return orderBy(query, defaultMappedSort);
  }
  if (!sort?.field) return query;
  const sortType = getStakePoolSortType(sort.field);
  const mappedSort = mapSort(sort);
  switch (sortType) {
    case 'data':
      return orderBy(query, [...mappedSort, { field: 'pool_id', order: 'asc' }]);
    case 'metrics':
      return orderBy(query, [...mappedSort, { field: 'id', order: 'asc' }]);
    case 'apy':
      return orderBy(query, [...mappedSort, { field: 'hash_id', order: 'asc' }]);
    default:
      return orderBy(query, [...mappedSort]);
  }
};

const Queries = {
  IDENTIFIER_QUERY,
  POOLS_WITH_PLEDGE_MET,
  STATUS_QUERY,
  findLastEpoch,
  findPoolAPY,
  findPoolEpochRewards,
  findPoolStats,
  findPools,
  findPoolsData,
  findPoolsMetrics,
  findPoolsOwners,
  findPoolsRegistrations,
  findPoolsRelays,
  findPoolsRetirements,
  findPoolsWithPledgeMet,
  findTotalAda
};

export default Queries;
