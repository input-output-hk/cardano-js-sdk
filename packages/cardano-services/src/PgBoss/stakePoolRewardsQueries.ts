export const accountActiveStake = `
SELECT amount AS value
FROM epoch_stake
WHERE epoch_no = $1
  AND addr_id = $2`;

export const poolDelegators = `
SELECT addr_id, view = ANY($3) AS owner
FROM delegation od
JOIN stake_address sa ON od.addr_id = sa.id
WHERE pool_hash_id = $2
  AND active_epoch_no <= $1
  AND NOT EXISTS (
    SELECT TRUE FROM delegation id
    WHERE id.addr_id = od.addr_id
      AND id.active_epoch_no <= $1
      AND (id.tx_id > od.tx_id OR (id.tx_id = od.tx_id AND id.cert_index > od.cert_index)))
  AND EXISTS (
    SELECT TRUE FROM stake_registration re
    WHERE re.addr_id = od.addr_id
      AND re.epoch_no <= $1
      AND NOT EXISTS (
        SELECT TRUE FROM stake_deregistration de
        WHERE de.addr_id = od.addr_id
          AND de.epoch_no <= $1
          AND (de.tx_id > re.tx_id OR (de.tx_id = re.tx_id AND de.cert_index > re.cert_index))))`;

export const poolRewards = `
SELECT amount, type FROM reward
WHERE earned_epoch = $1
  AND pool_id = $2
  AND type IN ('leader', 'member')`;
