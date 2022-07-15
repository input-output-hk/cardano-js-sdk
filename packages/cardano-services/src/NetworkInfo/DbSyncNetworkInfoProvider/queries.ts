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
        SELECT
            SUM(tx_out.value) AS utxo_amount
        FROM tx_out
        LEFT JOIN tx_in 
            ON tx_out.tx_id = tx_in.tx_out_id
            AND tx_out.index = tx_in.tx_out_index
        WHERE tx_in.id IS NULL    
    )
    SELECT CAST(utxo_amount + (rewards_amount - withdrawals_amount) AS BIGINT) as circulating_supply
    FROM total_rewards, total_withdrawals, total_utxo
`;

export const findTotalSupply = `
    SELECT CAST($1 - reserves AS BIGINT) AS total_supply
    FROM ada_pots
    ORDER BY ada_pots.block_id DESC 
    LIMIT 1
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

export const findLedgerTip = `
    SELECT block_no, slot_no, hash
    FROM block
    ORDER BY block_no DESC NULLS LAST
    LIMIT 1;
`;

export const findCurrentWalletProtocolParams = `
    SELECT 
    min_fee_a, 
    min_fee_b, max_tx_size, 
    key_deposit, 
    pool_deposit, 
    protocol_major, 
    protocol_minor, 
    min_pool_cost, 
    coins_per_utxo_size, 
    max_val_size, 
    max_collateral_inputs
    FROM public.epoch_param
    ORDER BY epoch_no DESC NULLS LAST
    LIMIT 1;
`;

const Queries = {
  findActiveStake,
  findCirculatingSupply,
  findCurrentWalletProtocolParams,
  findLatestCompleteEpoch,
  findLedgerTip,
  findLiveStake,
  findTotalSupply
};

export default Queries;
