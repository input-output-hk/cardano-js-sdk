export const stakeAddress = `
  SELECT
    addr_id, stake_address.view as address, amount, earned_epoch as reward_epoch_no, NULL as treasury_tx_id
  FROM
    reward
  JOIN stake_address ON stake_address.id=reward.addr_id ORDER BY reward_epoch_no ASC LIMIT $1`;

const Queries = {
  stakeAddress
};

export default Queries;
