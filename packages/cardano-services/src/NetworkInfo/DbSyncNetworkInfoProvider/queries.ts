export const findCirculatingSupply = `
    WITH total_rewards AS (
        SELECT COALESCE(SUM(amount), 0) as rewards_amount
        FROM reward
    ),
    total_withdrawals AS (
        SELECT COALESCE(SUM(amount), 0) as withdrawals_amount
        FROM withdrawal
    ),
    total_utxo AS (
        SELECT COALESCE(SUM(value)) AS utxo_amount
        FROM tx_out AS tx_outer WHERE
        NOT exists
            ( SELECT tx_out.id
        FROM tx_out
        JOIN tx_in on
        tx_out.tx_id = tx_in.tx_out_id AND
        tx_out.index = tx_in.tx_out_index
        WHERE tx_outer.id = tx_out.id)
    )
    SELECT CAST(utxo_amount + (rewards_amount - withdrawals_amount) AS BIGINT) as circulating_supply
    FROM total_rewards, total_withdrawals, total_utxo
`;

export const findTotalSupply = `
    WITH total_reserves AS (
        SELECT CAST(COALESCE(SUM(reserves),0) AS BIGINT) as reserves_amount
        FROM ada_pots
            WHERE ada_pots.epoch_no = (
            SELECT no FROM epoch
            ORDER BY id DESC 
            LIMIT 1
        )
    )

    SELECT CAST($1 - reserves_amount AS BIGINT) as total_supply
    FROM total_reserves   
`;

// Live stake is the current epoch’s delegated stake that has yet to be snapshotted
export const findLiveStake = `
    WITH current_delegation AS (
        SELECT DISTINCT ON (delegation.addr_id) delegation.addr_id,
    delegation.pool_hash_id
    FROM delegation
    ORDER BY delegation.addr_id, delegation.slot_no DESC, delegation.pool_hash_id 
    )

    SELECT CAST(COALESCE(SUM(tx_out.value), 0) AS BIGINT) AS live_stake
    FROM tx_out 
    LEFT JOIN tx_in ON tx_out.tx_id = tx_in.tx_out_id AND tx_out.index::smallint = tx_in.tx_out_index::smallint
    LEFT JOIN current_delegation ON current_delegation.addr_id = tx_out.stake_address_id 
    LEFT JOIN stake_address ON stake_address.id = current_delegation.addr_id 

    WHERE 
        tx_in.tx_in_id IS NULL
`;

// Active stake is the stake snapshot from n-1 epochs, where n = current epoch
// epoch_stake contains records of completed epochs
export const findActiveStake = `
    SELECT CAST(COALESCE(SUM(amount), 0) AS BIGINT) as active_stake
    FROM epoch_stake
    WHERE epoch_stake.epoch_no = (
    SELECT no FROM epoch
        ORDER BY no DESC
        LIMIT 1
    )
`;

export const findLatestCompleteEpoch = `
    SELECT no
    FROM public.epoch
    ORDER BY no DESC
    LIMIT 1
`;

const Queries = {
  findActiveStake,
  findCirculatingSupply,
  findLatestCompleteEpoch,
  findLiveStake,
  findTotalSupply
};

export default Queries;
