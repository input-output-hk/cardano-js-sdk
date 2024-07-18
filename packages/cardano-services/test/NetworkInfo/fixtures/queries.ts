export const getMaxSupply = `
  SELECT (treasury + reserves + rewards + utxo + deposits_stake + deposits_drep + deposits_proposal + fees) as max_supply
  FROM ada_pots
  ORDER BY epoch_no desc
  LIMIT 1
`;

export const lastKnownEpoch = 'select no from epoch order by id desc limit 1';

const Queries = {
  getMaxSupply,
  lastKnownEpoch
};

export default Queries;
