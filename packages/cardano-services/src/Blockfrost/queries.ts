export const findCurrentEpoch = `
SELECT
  MAX(no) AS epoch_no
FROM epoch
`;

export const findFirstUpdateAfterBlock = `
SELECT
  active_epoch_no
FROM pool_update
JOIN tx ON
  tx.id = registered_tx_id
JOIN block ON
  block_id = block.id AND
  block_no > $2
WHERE hash_id = $1
ORDER BY block_no DESC
LIMIT 1
`;

export const findLastRetire = `
SELECT
  block_no,
  retiring_epoch
FROM pool_retire
JOIN tx ON
  tx.id = announced_tx_id
JOIN block ON
  block_id = block.id
WHERE hash_id = $1
ORDER BY block_no DESC
LIMIT 1
`;

export const findPools = `
SELECT
  id,
  view
FROM pool_hash
LEFT JOIN blockfrost.pool_metric ON
  id = pool_hash_id
WHERE
  COALESCE(cache_time, 0) < $1
`;

export const setPoolMetric = `
INSERT INTO blockfrost.pool_metric
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
ON CONFLICT (pool_hash_id)
DO UPDATE SET
  last_reward_epoch = $2,
  cache_time = $3,
  blocks_created = $4,
  delegators = $5,
  active_stake = $6,
  live_stake = $7,
  live_pledge = $8,
  saturation = $9,
  reward_address = $10,
  extra = $11,
  status = $12
`;
