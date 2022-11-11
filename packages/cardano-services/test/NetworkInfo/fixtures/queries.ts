export const getMaxSupply = `
  SELECT (treasury + reserves + rewards + utxo + deposits + fees) as max_supply
  FROM ada_pots
  ORDER BY epoch_no desc
  LIMIT 1
`;

const Queries = {
  getMaxSupply
};

export default Queries;
