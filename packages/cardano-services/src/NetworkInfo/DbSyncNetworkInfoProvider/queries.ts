export const findCirculatingSupply = `
  SELECT ( utxo + rewards ) as circulating_supply FROM ada_pots ORDER BY id DESC LIMIT 1;
`;

export const findTotalSupply = `
    SELECT CAST($1 - reserves AS BIGINT) AS total_supply
    FROM ada_pots
    ORDER BY ada_pots.block_id DESC 
    LIMIT 1
`;

// Active stake is the stake snapshot from n-1 epochs, where n = current epoch
// epoch_stake contains records of completed epochs
export const findActiveStake = `
    SELECT CAST(COALESCE(SUM(amount), 0) AS BIGINT) as active_stake
    FROM epoch_stake
    WHERE epoch_stake.epoch_no = (SELECT MAX(no) FROM epoch) - 1
`;

export const findLatestCompleteEpoch = `
    SELECT no
    FROM public.epoch
    ORDER BY no DESC
    LIMIT 1
`;

export const findProtocolParams = `
    SELECT 
    min_fee_a, 
    min_fee_b, 
    max_tx_size,
    key_deposit, 
    pool_deposit, 
    protocol_major, 
    protocol_minor, 
    min_pool_cost, 
    coins_per_utxo_size, 
    max_val_size, 
    max_collateral_inputs,
    max_block_size,
    max_bh_size,
    optimal_pool_count,
    influence,
    monetary_expand_rate,
    treasury_growth_rate,
    decentralisation,
    collateral_percent,
    price_mem,
    price_step,
    max_tx_ex_mem,
    max_tx_ex_steps,
    max_block_ex_mem,
    max_block_ex_steps,
    max_epoch,
    gov_action_deposit,
    drep_deposit,
    cost_model.costs,
    committee_min_size,
    committee_max_term_length,
    gov_action_lifetime,
    FROM epoch_param
    LEFT JOIN cost_model
        ON cost_model.id = epoch_param.cost_model_id
    ORDER BY epoch_no DESC NULLS LAST
    LIMIT 1;
`;

const Queries = {
  findActiveStake,
  findCirculatingSupply,
  findLatestCompleteEpoch,
  findProtocolParams,
  findTotalSupply
};

export default Queries;
