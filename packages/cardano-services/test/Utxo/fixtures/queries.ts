export const findAddresses = `
  SELECT
    tx_out.address AS address
  FROM tx_out
  JOIN tx ON tx_out.tx_id = tx.id
  ORDER BY tx_out.id DESC
  LIMIT $1`;

export const beingMultiAssetAddresses = `
  SELECT
    tx_out.address as address
  FROM ma_tx_out AS ma_out
  JOIN multi_asset AS ma_id ON ma_out.ident = ma_id.id
  JOIN tx_out ON tx_out.id = ma_out.tx_out_id
  JOIN tx ON tx_out.tx_id = tx.id
`;

export const withMultiAssetWithoutName = `
  WHERE octet_length(name) = 0`;

export const endMultiAssetAddresses = `
  GROUP BY tx_out.address
  LIMIT $1`;

export const findAddressWithInlineDatumUtxo = `
  SELECT 
    tx_outer.address
  FROM tx_out AS tx_outer
  JOIN tx ON tx.id = tx_outer.tx_id 
  LEFT JOIN datum
    ON datum.id = tx_outer.inline_datum_id
  WHERE NOT EXISTS
    ( SELECT tx_out.id
    FROM tx_out
    JOIN tx_in on
    tx_out.tx_id = tx_in.tx_out_id AND
    tx_out.index = tx_in.tx_out_index
  WHERE tx_outer.id = tx_out.id
    ) AND datum.bytes IS NOT NULL
  ORDER BY tx_outer.id ASC
  LIMIT $1`;

export const findAddressWithScriptRefUtxo = `
  SELECT 
    tx_outer.address
  FROM tx_out AS tx_outer
  JOIN tx ON tx.id = tx_outer.tx_id 
  LEFT JOIN script
    ON script.id = tx_outer.reference_script_id
  WHERE NOT EXISTS
    ( SELECT tx_out.id
    FROM tx_out
    JOIN tx_in on
    tx_out.tx_id = tx_in.tx_out_id AND
    tx_out.index = tx_in.tx_out_index
  WHERE tx_outer.id = tx_out.id
    ) AND script.type = $2
  ORDER BY tx_outer.id ASC
  LIMIT $1`;

const Queries = {
  beingMultiAssetAddresses,
  endMultiAssetAddresses,
  findAddressWithInlineDatumUtxo,
  findAddressWithScriptRefUtxo,
  findAddresses,
  withMultiAssetWithoutName
};

export default Queries;
