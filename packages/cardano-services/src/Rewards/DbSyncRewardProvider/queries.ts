export const findAccountBalance = `
    WITH current_epoch AS (
        SELECT
            e."no" AS epoch_no,
            optimal_pool_count
        FROM epoch e
        JOIN epoch_param ep ON
            ep.epoch_no = e."no"
        ORDER BY e.no DESC LIMIT 1
    )
    SELECT 
    (
        SELECT COALESCE(SUM(r.amount),0) 
        FROM reward r
        JOIN stake_address ON 
            stake_address.id = r.addr_id
        WHERE stake_address.view = $1
        AND r.spendable_epoch <= (SELECT epoch_no FROM current_epoch)
    ) - (
        SELECT COALESCE(SUM(w.amount),0) 
        FROM withdrawal w
        JOIN stake_address ON stake_address.id = w.addr_id
        WHERE stake_address.view = $1
    ) AS balance
`;

export const findRewardsHistory = (lowerBound?: number, upperBound?: number) => {
  const whereConditions = [];
  if (lowerBound) whereConditions.push(`"no" >= ${lowerBound}`);
  if (upperBound) whereConditions.push(`"no" <= ${upperBound}`);
  const whereSentence = whereConditions.length > 0 ? `WHERE ${whereConditions.join(' AND ')}` : '';
  return `
  WITH epochs AS (
      SELECT 
          id,
          no AS epoch_no
      FROM epoch
      ${whereSentence}
  )
  SELECT
      SUM(r.amount) AS quantity,
      sa."view" AS address,
      r.earned_epoch AS epoch,
      ph."view" as pool_id
  FROM reward r
  JOIN stake_address sa ON
      sa.id = r.addr_id AND 
      sa."view" = ANY($1)
  JOIN epochs ON 
      r.earned_epoch = epochs.epoch_no
  JOIN pool_hash ph ON 
      r.pool_id = ph.id
  GROUP BY sa."view", r.earned_epoch, ph."view"
  ORDER BY quantity ASC
`;
};
