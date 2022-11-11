export const findTxWithMetadata = `
  SELECT 
    tx.hash AS tx_id
  FROM tx_metadata AS meta
  JOIN tx ON meta.tx_id = tx.id
  ORDER BY meta.id ASC
  LIMIT $1;`;

const Queries = {
  findTxWithMetadata
};

export default Queries;
