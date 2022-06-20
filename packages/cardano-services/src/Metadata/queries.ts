export const findTxMetadata = `
	SELECT 
		meta."key" AS "key",
		meta."json" AS json_value,
		tx.hash AS tx_id
	FROM tx_metadata AS meta
	JOIN tx ON meta.tx_id = tx.id
	WHERE tx.hash = ANY($1)
	ORDER BY meta.id ASC`;
