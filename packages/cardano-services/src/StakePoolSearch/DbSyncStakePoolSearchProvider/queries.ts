/* eslint-disable sonarjs/no-nested-template-literals */
import { Cardano, MultipleChoiceSearchFilter, StakePoolQueryOptions } from '@cardano-sdk/core';
import { SubQuery } from './types';

export const findLastEpoch = `
 SELECT 
  "no"
 FROM epoch
 ORDER BY id DESC 
 LIMIT 1
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
  update_id
  ipv4,
  ipv6,
  port,
  dns_name,
  dns_srv_name AS hostname --fixme: check this is correct
FROM pool_relay
WHERE update_id = ANY($1)
`;
// TODO: probably this should be filtered by registration tx_id = last_update.registration_tx_id
export const findPoolsOwners = `
SELECT 
  DISTINCT stake.view AS address,
  owner.pool_hash_id AS hash_id
FROM pool_owner owner
JOIN stake_address stake
  ON stake.id = owner.addr_id
WHERE owner.pool_hash_id = ANY($1)
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
      pu.id as update_id,
      pu.active_epoch_no,
      pu.pledge,
      sa.id as stake_address_id
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
    JOIN delegation d2 ON
      d2.addr_id = sa.id AND
      (d2.active_epoch_no <= (SELECT "no" FROM current_epoch)) AND
      d2.pool_hash_id = ph.id`
  },
  {
    id: { name: 'pool_owner_rewards' },
    query: `
  SELECT 
    COALESCE(SUM(r.amount),0) as total_amount,
    sa.id as stake_address_id,
    r.pool_id
  FROM reward r
  JOIN stake_address sa ON 
      sa.id = r.addr_id
  WHERE sa.id in (select stake_address_id from pools_delegated) and
    r.spendable_epoch <= (SELECT "no" FROM current_epoch)
  GROUP BY r.pool_id, sa.id`
  },
  {
    id: { name: 'pool_owner_withdraws' },
    query: ` 
  SELECT 
    COALESCE(SUM(w.amount),0)  as total_amount,
    sa.id as stake_address_id
  FROM withdrawal w
  JOIN tx ON tx.id = w.tx_id AND 
    tx.valid_contract = TRUE
  JOIN stake_address sa ON sa.id = w.addr_id
  join pools_delegated pool on pool.stake_address_id = sa.id 
  group by sa.id`
  },
  {
    id: { name: 'reward_acc_balance' },
    query: `
  select 
    (r.total_amount - w.total_amount)  as total_amount,
    r.stake_address_id,
    r.pool_id 
  from pool_owner_rewards r
  join pool_owner_withdraws w 
    on r.stake_address_id = w.stake_address_id `
  },
  {
    id: { name: 'owners_utxo' },
    query: `
  SELECT
    tx_out.value as value,
    o.pool_hash_id 
  FROM tx_out
  join pool_owner o on 
    o.addr_id = tx_out.stake_address_id and 
    o.pool_hash_id in (select id from pools_delegated)
  LEFT JOIN tx_in ON 
    tx_out.tx_id = tx_in.tx_out_id AND 
    tx_out.index::smallint = tx_in.tx_out_index::smallint
  LEFT JOIN tx as tx_in_tx ON 
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
    SUM(value) as total_amount,
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
    LEFT join pool_offline_data pod 
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
  ph.view as pool_id,
  sa.view as reward_address,
  pu.reward_addr,
  pu.pledge,
  pu.fixed_cost,
  pu.margin,
  pu.vrf_key_hash,
  metadata.url AS metadata_url, 
  metadata.hash AS metadata_hash,
  pod.json AS offline_data
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
  const condition = ` ${identifier.condition} ` || ' or ';
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
      `(COALESCE(pr.retiring_epoch,0) > (select "no" from current_epoch) 
          AND COALESCE(pr.retiring_epoch,0) > ${activeEpochColumn})`
    );
  if (status.includes(Cardano.StakePoolStatus.Retired))
    whereClause.push(
      `(COALESCE(pr.retiring_epoch,0) <= (select "no" from current_epoch) 
          AND COALESCE(pr.retiring_epoch,0) > ${activeEpochColumn})`
    );
  if (status.includes(Cardano.StakePoolStatus.Activating))
    whereClause.push(
      `(${activeEpochColumn} > (select "no" from current_epoch) 
          AND COALESCE(pr.retiring_epoch,0) <= ${activeEpochColumn})`
    );
  if (status.includes(Cardano.StakePoolStatus.Active))
    whereClause.push(
      `(${activeEpochColumn} <= (select "no" from current_epoch) 
          AND COALESCE(pr.retiring_epoch,0) < ${activeEpochColumn})`
    );
  return `(${whereClause.join(' OR ')})`;
};

export const withPagination = (query: string, pagination?: StakePoolQueryOptions['pagination']) => {
  if (pagination) return `${query} OFFSET ${pagination.startAt} LIMIT ${pagination.limit}`;
  return query;
};

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
    `;
};

const Queries = {
  IDENTIFIER_QUERY,
  POOLS_WITH_PLEDGE_MET,
  STATUS_QUERY,
  findLastEpoch,
  findPools,
  findPoolsData,
  findPoolsOwners,
  findPoolsRegistrations,
  findPoolsRelays,
  findPoolsRetirements,
  findPoolsWithPledgeMet
};

export default Queries;
