export const withMeta = (withMetadata: boolean) => `AND pr.metadata_url IS ${withMetadata ? 'NOT' : ''} NULL`;

export const findStakePools = (hasMetadata = false) => `
    SELECT 
    sp.id, sp.status, pr.reward_account, pr.pledge, 
    pr.cost, pr.margin,pr.relays, pr.owners, pr.vrf, 
    pr.metadata_url, pr.metadata_hash, pr.block_slot, 
    pm.name, pm.ticker, pm.description, pm.homepage, 
    pm.ext, cpm.live_saturation, cpm.apy
    FROM public.stake_pool as sp
        LEFT JOIN pool_registration as pr ON sp.last_registration_id = pr.id
        LEFT JOIN pool_metadata as pm ON pr.id = pm.pool_update_id
        LEFT JOIN current_pool_metrics as cpm ON pr.stake_pool_id = cpm.stake_pool_id
    WHERE sp.status = ANY($2)
    ${hasMetadata ? withMeta(hasMetadata) : ''}
    LIMIT $1
`;
