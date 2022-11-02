export const withoutMetadata = `
  SELECT policy, name
  FROM ma_tx_mint AS mint
  JOIN multi_asset AS ma ON mint.ident = ma.id
  WHERE mint.tx_id not in (SELECT tx_id FROM tx_metadata)
  LIMIT $1`;

export const withCIP25Metadata = `
  SELECT policy, name, json
  FROM ma_tx_mint AS mint
  JOIN multi_asset AS ma ON mint.ident = ma.id
  JOIN tx_metadata AS meta ON meta.tx_id = mint.tx_id
  JOIN tx ON tx.id = mint.tx_id
  WHERE meta.key = 721
  ORDER BY mint.id DESC
  LIMIT $1`;

export const findMultiAssetHistory = `
  SELECT tx.hash AS hash, mint.quantity AS quantity
  FROM ma_tx_mint AS mint
  JOIN multi_asset AS ma ON mint.ident = ma.id
  JOIN tx ON tx.id = mint.tx_id
  WHERE ma.policy = $1 AND ma.name = $2
`;

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

const Queries = {
  findLastNftMintTx,
  findMultiAssetHistory,
  withCIP25Metadata,
  withoutMetadata
};

export default Queries;
