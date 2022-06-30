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

export interface FindLastMintTxModel {
  tx_hash: Buffer;
}
