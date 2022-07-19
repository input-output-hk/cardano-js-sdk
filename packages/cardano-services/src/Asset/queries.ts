export const findLastNftMintTx = `
	SELECT tx.hash AS tx_hash
	FROM ma_tx_mint AS mint
	JOIN multi_asset AS ma ON mint.ident = ma.id
	JOIN tx_metadata AS meta ON meta.tx_id = mint.tx_id
	JOIN tx ON tx.id = mint.tx_id
	WHERE ma.policy = $1 AND ma.name = $2 AND meta.key = 721
	ORDER BY mint.id DESC
	LIMIT 1
`;

export const findMultiAsset = `
	SELECT id, fingerprint
	FROM multi_asset
	WHERE policy = $1 AND name = $2
`;

export const findMultiAssetHistory = `
	SELECT tx.hash AS hash, mint.quantity AS quantity
	FROM ma_tx_mint AS mint
	JOIN multi_asset AS ma ON mint.ident = ma.id
	JOIN tx ON tx.id = mint.tx_id
	WHERE ma.policy = $1 AND ma.name = $2
`;

export const findMultiAssetQuantities = `
	SELECT COUNT(*) AS count, SUM(quantity) AS sum
	FROM ma_tx_mint
	WHERE ident = $1
`;

const Queries = {
  findLastNftMintTx,
  findMultiAsset,
  findMultiAssetHistory,
  findMultiAssetQuantities
};

export default Queries;
