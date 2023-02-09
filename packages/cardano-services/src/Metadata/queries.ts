export const findTxMetadata = `
SELECT
  key,
  bytes,
  hash AS tx_id
FROM tx_metadata AS meta
JOIN tx ON tx_id = tx.id
WHERE hash = ANY($1)
ORDER BY meta.id ASC`;
