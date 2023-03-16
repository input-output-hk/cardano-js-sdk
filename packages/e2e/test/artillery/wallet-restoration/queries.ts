/**
 * Query distinct addresses from db associated with users who are staking.
 */
export const findAddressesWithRegisteredStakeKey = `
    SELECT COUNT(*) AS tx_count, address, sa.view as stake_address
    FROM tx_out 
    LEFT JOIN public.stake_address sa 
    ON tx_out.stake_address_id = sa.id 
    WHERE tx_out.id stake_address_id IS NOT NULL 
    GROUP BY address, stake_address 
    ORDER BY address DESC LIMIT $1;
`;
