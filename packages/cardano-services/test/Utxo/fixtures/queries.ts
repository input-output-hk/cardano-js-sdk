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

const Queries = {
  beingMultiAssetAddresses,
  endMultiAssetAddresses,
  findAddresses,
  withMultiAssetWithoutName
};

export default Queries;
