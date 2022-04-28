export const findUtxosByAddresses = `
SELECT 
    tx_outer.address,
    tx_outer.value AS coins,
    tx_outer.index,
    ENCODE(tx.hash, 'hex') AS tx_id,
    ma_tx_out.quantity AS asset_quantity,
    ENCODE(asset.name,'hex') AS asset_name,
    ENCODE(asset.policy,'hex') AS asset_policy,
    ENCODE(tx_outer.data_hash,'hex') AS data_hash
FROM tx_out AS tx_outer
JOIN tx ON tx.id = tx_outer.tx_id 
LEFT JOIN ma_tx_out 
  ON ma_tx_out.tx_out_id = tx_outer.id
LEFT JOIN multi_asset as asset
  ON asset.id = ma_tx_out.ident
WHERE NOT EXISTS
  ( SELECT tx_out.id
  FROM tx_out
  JOIN tx_in on
  tx_out.tx_id = tx_in.tx_out_id AND
  tx_out.index = tx_in.tx_out_index
WHERE tx_outer.id = tx_out.id
  ) AND address = ANY($1)
`;
