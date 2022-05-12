export const findAccountBalance = `
    SELECT 
    (
        SELECT COALESCE(SUM(r.amount),0) 
        FROM reward r
        JOIN stake_address ON 
            stake_address.id = r.addr_id
        WHERE stake_address.view = $1
    ) - (
        SELECT COALESCE(SUM(w.amount),0) 
        FROM withdrawal w
        JOIN tx ON tx.id = w.tx_id AND 
            tx.valid_contract = TRUE
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
      r.earned_epoch AS epoch
  FROM reward r
  JOIN stake_address sa ON
      sa.id = r.addr_id AND 
      sa."view" = ANY($1)
  JOIN epochs ON 
      r.earned_epoch = epochs.epoch_no
  GROUP BY sa."view", r.earned_epoch
  ORDER BY quantity ASC
`;
};
