/**
 * Query randomized distinct addresses from db associated with users who are staking.
 */
export const findAddressesWithRegisteredStakeKey = `
  SELECT * FROM (
    SELECT DISTINCT txOut.address as address, sa.view as stake_address
    FROM public.delegation d
      LEFT JOIN public.tx_out txOut on
    d.addr_id = txOut.stake_address_id
      LEFT JOIN public.stake_address sa on
    txOut.stake_address_id = sa.id
  ) distinct_addresses
  ORDER BY RANDOM() LIMIT $1
`;
