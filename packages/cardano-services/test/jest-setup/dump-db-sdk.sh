 #!/usr/bin/env bash

# In order to test our queries we can populate the test db with some real testnet data. 
# We are already importing a testnet snapshot but using a whole testnet snapshot will be huge (+3GB) so, 
# alternatively, we selecting and importing some blocks data. 
# It's not an ideal solution as we need to relax some constraints to do so
# but still is better than inserting data manually. This script uses a similar process as 
# `pg_dump` using COPY statements
#
# This script helps dumping some information based on block ids.
#
# To run this file, grab a testnet db-sync postgres db and execute
#
# $ bash dump_db-sdk.sh
#
# A resulting file like `fixture_data.sql` can then be either importer or compressed `tar` to be used
# in our e2e tests
# 
# Usage with passing db password:
#
# PGPASSWORD=your_db_pass ./dump-db-sdk.sh
#
# Make sure to replace 'DB' value with your local db credentials to establish connection from the script

DB="-U cardano -h 127.0.0.1 -p 5438 -d cardanodbsync"

OUT_FILE='./testnet-fixture-data.sql'
TAR_FILE='./testnet-fixture-data.tar'


# Block Ids. Ideally we need to export them in batches of 3 as when we skip Epoch Boundary Blocks checking 3 blocks 
# before the one we are interested, so, if you are willing to fetch a block, please state B-2, B-1, B
# See: cardano-rosetta-server/src/server/db/queries/blockchain-queries.ts#findBlock
BLOCKS_TO_EXPORT="1833726,1598507,1622869,1646557,1654555,1655520,1668437,1682503,1912426,2672896,2759361,2769413,2769469,2769577,2972717,3087425,3157934,3274726, 3556390"
SELECT_BLOCK_ID="SELECT id FROM block WHERE block_no IN ($BLOCKS_TO_EXPORT)"
SELECT_BLOCK_EPOCH="SELECT epoch_no FROM block WHERE block_no IN ($BLOCKS_TO_EXPORT)"
  
echo "-- Dumping blocks $BLOCKS_TO_EXPORT" > $OUT_FILE;

# Adding alter tables on TX table corresponding to db-sync v7.1.0 migrations
echo "ALTER TABLE public.tx ADD COLUMN invalid_before word64type NULL;" >> $OUT_FILE;
echo "ALTER TABLE public.tx ADD COLUMN invalid_hereafter word64type NULL;" >> $OUT_FILE;

echo "ALTER TABLE public.block DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.block (id, hash, epoch_no, slot_no, epoch_slot_no, block_no, previous_id, slot_leader_id, size, "time", tx_count, proto_major, proto_minor, vrf_key, op_cert, op_cert_counter) FROM stdin WITH CSV;' >> $OUT_FILE
psql -c "\copy (SELECT * from block WHERE block_no in ($BLOCKS_TO_EXPORT)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping transactions" >> $OUT_FILE;
echo "ALTER TABLE public.tx DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.tx (id, hash, block_id, block_index, out_sum, fee, deposit, size, invalid_before, invalid_hereafter, valid_contract, script_size) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from tx WHERE block_id in ($SELECT_BLOCK_ID)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

SELECT_TX_ID="(SELECT id from tx WHERE block_id IN ($SELECT_BLOCK_ID))"

echo "-- Dumping transaction inputs" >> $OUT_FILE;
echo "ALTER TABLE public.tx_in DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.tx_in (id, tx_in_id, tx_out_id, tx_out_index, redeemer_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from tx_in WHERE tx_in_id IN $SELECT_TX_ID) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

# Inputs require the source tx to be able to compute the amount
# TODO: Check if this query can be improved as it's a copy from the one we use to query the data
INPUT_TX_QUERY="
  tx
JOIN tx_in
  ON tx_in.tx_in_id = tx.id
JOIN tx_out as source_tx_out
  ON tx_in.tx_out_id = source_tx_out.tx_id
  AND tx_in.tx_out_index = source_tx_out.index
JOIN tx as source_tx
  ON source_tx_out.tx_id = source_tx.id
WHERE
  tx.id = ANY ($SELECT_TX_ID) AND
  source_tx.id NOT IN ($SELECT_TX_ID)
"

WITHDRAWAL_ADDRESSES_QUERY="
SELECT addr_id 
FROM withdrawal 
WHERE tx_id IN $SELECT_TX_ID"

DEREGISTRATION_ADDRESSES_QUERY="
SELECT addr_id 
FROM stake_deregistration 
WHERE tx_id IN $SELECT_TX_ID"

DELEGATIONS_ADDRESSES_QUERY="
SELECT addr_id 
FROM delegation 
WHERE tx_id IN $SELECT_TX_ID"

REGISTRATION_ADDRESSES_QUERY="
SELECT addr_id 
FROM stake_registration 
WHERE tx_id IN $SELECT_TX_ID"

REWARD_ADDRESSES_QUERY="
SELECT addr_id
FROM reward 
WHERE spendable_epoch IN ($SELECT_BLOCK_EPOCH) 
OR earned_epoch IN ($SELECT_BLOCK_EPOCH)
"

REWARDS_POOL_HASH_QUERY="
SELECT pool_id 
FROM reward 
WHERE (spendable_epoch in ($SELECT_BLOCK_EPOCH)
OR earned_epoch IN ($SELECT_BLOCK_EPOCH))
AND pool_id IS NOT NULL
"

DELEGATIONS_POOL_HASH_QUERY="
SELECT pool_hash_id 
FROM delegation 
WHERE tx_id IN $SELECT_TX_ID
"

TX_OUT_IDS_QUERY="
SELECT id
FROM tx_out
WHERE tx_id IN ($SELECT_TX_ID)
"
POOL_UPDATE_METADATA_ID_QUERY="
SELECT meta_id
FROM pool_update
WHERE registered_tx_id IN ($SELECT_TX_ID)
"
POOL_UPDATE_POOL_HASH_QUERY="
SELECT hash_id
FROM pool_update 
WHERE registered_tx_id IN ($SELECT_TX_ID)"

POOL_RETIRE_POOL_HASH_QUERY="
SELECT hash_id
FROM pool_retire
WHERE announced_tx_id IN ($SELECT_TX_ID)
"
OWNERS_ADDRESSES_QUERY="
SELECT addr_id
FROM pool_owner
WHERE registered_tx_id IN ($SELECT_TX_ID)
  AND pool_hash_id IN ($POOL_UPDATE_POOL_HASH_QUERY)
"
MA_TX_OUT_IDS_QUERY="SELECT ident FROM ma_tx_out WHERE tx_out_id IN ($TX_OUT_IDS_QUERY)"
MA_TX_MINT_IDS_QUERY="SELECT ident FROM ma_tx_mint WHERE tx_id IN ($SELECT_TX_ID)"

echo "-- Dumping transaction inputs references where spent outputs were defined" >> $OUT_FILE;
echo 'COPY public.tx (id, hash, block_id, block_index, out_sum, fee, deposit, size, invalid_before, invalid_hereafter, valid_contract, script_size) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT source_tx.* FROM $INPUT_TX_QUERY) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "ALTER TABLE public.tx_out DISABLE TRIGGER ALL;" >> $OUT_FILE;

echo "-- Dumping spent outputs" >> $OUT_FILE;
echo 'COPY public.tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT source_tx_out.* FROM $INPUT_TX_QUERY) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping transactions outputs" >> $OUT_FILE;
echo 'COPY public.tx_out (id, tx_id, index, address, address_raw, address_has_script, payment_cred, stake_address_id, value, data_hash) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from tx_out WHERE tx_id IN $SELECT_TX_ID) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping transactions withdrawals" >> $OUT_FILE;
echo "ALTER TABLE public.withdrawal DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.withdrawal (id, addr_id, amount, redeemer_id, tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from withdrawal WHERE tx_id IN $SELECT_TX_ID) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping Block transaction withdrawals stake addresses" >> $OUT_FILE;
echo "ALTER TABLE public.stake_address DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.stake_address (id, hash_raw, view, script_hash, registered_tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from stake_address WHERE id IN ($WITHDRAWAL_ADDRESSES_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping Block transactions stake_registrations" >> $OUT_FILE;
echo "ALTER TABLE public.stake_registration DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.stake_registration (id, addr_id, cert_index, epoch_no, tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * FROM stake_registration WHERE tx_id IN $SELECT_TX_ID) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping Block transactions stake_registrations stake addresses" >> $OUT_FILE;
echo "ALTER TABLE public.stake_address DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.stake_address (id, hash_raw, view, script_hash, registered_tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from stake_address WHERE id IN ($REGISTRATION_ADDRESSES_QUERY) AND id NOT IN ($WITHDRAWAL_ADDRESSES_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

# dumping rewards of address stake1uyqq2a22arunrft3k9ehqc7yjpxtxjmvgndae80xw89mwyge9skyp to handle 'should sum all rewards and subtract all withdrawals till block 4853177' test case
echo "-- Dumping Block rewards" >> $OUT_FILE;
echo "ALTER TABLE public.reward DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.reward (id, addr_id, type, amount, earned_epoch, spendable_epoch,  pool_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from reward WHERE spendable_epoch in ($SELECT_BLOCK_EPOCH) OR earned_epoch IN ($SELECT_BLOCK_EPOCH) OR addr_id = 12126) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping Block rewards stake_addresses" >> $OUT_FILE;
echo "ALTER TABLE public.stake_address DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.stake_address (id, hash_raw, view, script_hash, registered_tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from stake_address WHERE id IN ($REWARD_ADDRESSES_QUERY) AND id NOT IN ($WITHDRAWAL_ADDRESSES_QUERY) AND id NOT IN ($REGISTRATION_ADDRESSES_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping Block rewards pool_hashes" >> $OUT_FILE;
echo "ALTER TABLE public.pool_hash DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.pool_hash (id, hash_raw, view) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from pool_hash WHERE id IN ($REWARDS_POOL_HASH_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping transactions deregistrations" >> $OUT_FILE;
echo "ALTER TABLE public.stake_deregistration DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.stake_deregistration (id, addr_id, cert_index, epoch_no, tx_id, redeemer_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from stake_deregistration WHERE tx_id IN $SELECT_TX_ID) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping Block transaction deregistrations stake addresses" >> $OUT_FILE;
echo "ALTER TABLE public.stake_address DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.stake_address (id, hash_raw, view, script_hash, registered_tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from stake_address WHERE id IN ($DEREGISTRATION_ADDRESSES_QUERY) AND id NOT IN ($REWARD_ADDRESSES_QUERY) AND id NOT IN ($WITHDRAWAL_ADDRESSES_QUERY) AND id NOT IN ($REGISTRATION_ADDRESSES_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping transactions delegations" >> $OUT_FILE;
echo "ALTER TABLE public.delegation DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.delegation (id, addr_id, cert_index, pool_hash_id, active_epoch_no, tx_id, slot_no, redeemer_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from delegation WHERE tx_id IN $SELECT_TX_ID) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping Block delegations pool_hashes" >> $OUT_FILE;
echo "ALTER TABLE public.pool_hash DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.pool_hash (id, hash_raw, view) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from pool_hash WHERE id IN ($DELEGATIONS_POOL_HASH_QUERY) AND id NOT IN ($REWARDS_POOL_HASH_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping Block transaction delegations stake addresses" >> $OUT_FILE;
echo "ALTER TABLE public.stake_address DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.stake_address (id, hash_raw, view, script_hash, registered_tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from stake_address WHERE id IN ($DELEGATIONS_ADDRESSES_QUERY) AND id NOT IN ($DEREGISTRATION_ADDRESSES_QUERY) AND id NOT IN ($REWARD_ADDRESSES_QUERY) AND id NOT IN ($WITHDRAWAL_ADDRESSES_QUERY) AND id NOT IN ($REGISTRATION_ADDRESSES_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping ma_tx_out" >> $OUT_FILE;
echo "ALTER TABLE public.ma_tx_out DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.ma_tx_out (id, quantity, tx_out_id, ident) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from ma_tx_out WHERE tx_out_id IN ($TX_OUT_IDS_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping multi_asset" >> $OUT_FILE;
echo "ALTER TABLE public.multi_asset DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.multi_asset (id, policy, name, fingerprint) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from multi_asset WHERE id IN ($MA_TX_OUT_IDS_QUERY) OR id IN ($MA_TX_MINT_IDS_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping pool update's pool_hash" >> $OUT_FILE;
echo "ALTER TABLE public.pool_hash DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.pool_hash (id, hash_raw, view) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from pool_hash WHERE id IN ($POOL_UPDATE_POOL_HASH_QUERY) AND id NOT IN ($DELEGATIONS_POOL_HASH_QUERY) AND id NOT IN ($REWARDS_POOL_HASH_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping pool registration's pool metadata" >> $OUT_FILE;
echo "ALTER TABLE public.pool_metadata_ref DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.pool_metadata_ref (id, pool_id, url, hash, registered_tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from pool_metadata_ref WHERE id IN ($POOL_UPDATE_METADATA_ID_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping addresses of pool owners" >> $OUT_FILE;
echo "ALTER TABLE public.stake_address DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.stake_address (id, hash_raw, view, script_hash, registered_tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from stake_address WHERE id IN ($OWNERS_ADDRESSES_QUERY) AND id NOT IN ($DELEGATIONS_ADDRESSES_QUERY) AND id NOT IN ($DEREGISTRATION_ADDRESSES_QUERY) AND id NOT IN ($REWARD_ADDRESSES_QUERY) AND id NOT IN ($WITHDRAWAL_ADDRESSES_QUERY) AND id NOT IN ($REGISTRATION_ADDRESSES_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping owners of pool registrations" >> $OUT_FILE;
echo "ALTER TABLE public.pool_owner DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.pool_owner (id, addr_id, pool_hash_id, registered_tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from pool_owner WHERE registered_tx_id IN ($SELECT_TX_ID) AND pool_hash_id IN ($POOL_UPDATE_POOL_HASH_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping pool registrations" >> $OUT_FILE;
echo "ALTER TABLE public.pool_update DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.pool_update (id, hash_id, cert_index, vrf_key_hash, pledge, reward_addr, active_epoch_no, meta_id, margin, fixed_cost, registered_tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from pool_update WHERE registered_tx_id IN ($SELECT_TX_ID)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping pool hashes of pool retirements" >> $OUT_FILE;
echo "ALTER TABLE public.pool_hash DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.pool_hash (id, hash_raw, view) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from pool_hash WHERE id IN ($POOL_RETIRE_POOL_HASH_QUERY) AND id NOT IN ($POOL_UPDATE_POOL_HASH_QUERY) AND id NOT IN ($DELEGATIONS_POOL_HASH_QUERY) AND id NOT IN ($REWARDS_POOL_HASH_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping pool retirements" >> $OUT_FILE;
echo "ALTER TABLE public.pool_retire DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.pool_retire (id, hash_id, cert_index, announced_tx_id, retiring_epoch) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from pool_retire WHERE announced_tx_id IN ($SELECT_TX_ID)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping epoch params" >> $OUT_FILE;
echo "ALTER TABLE public.epoch_param DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.epoch_param (id,epoch_no,min_fee_a,min_fee_b,max_block_size,max_tx_size,max_bh_size,key_deposit,pool_deposit,max_epoch,
optimal_pool_count,influence,monetary_expand_rate,treasury_growth_rate, decentralisation,entropy,protocol_major,protocol_minor,min_utxo_value,
min_pool_cost,nonce,coins_per_utxo_word,cost_model_id,price_mem,price_step,max_tx_ex_mem,max_tx_ex_steps,max_block_ex_mem,max_block_ex_steps,max_val_size,
collateral_percent,max_collateral_inputs,block_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from epoch_param WHERE epoch_no IN ($SELECT_BLOCK_EPOCH)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping transactions metadata" >> $OUT_FILE;
echo "ALTER TABLE public.tx_metadata DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.tx_metadata (id, key, json, bytes, tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from tx_metadata WHERE tx_id IN ($SELECT_TX_ID)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping pool offline metadata" >> $OUT_FILE;
echo "ALTER TABLE public.pool_offline_data DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.pool_offline_data (id, pool_id, ticker_name, hash, json, bytes, pmr_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from pool_offline_data WHERE pmr_id IN ($POOL_UPDATE_METADATA_ID_QUERY)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping epochs" >> $OUT_FILE;
echo "ALTER TABLE public.epoch DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.epoch (id, out_sum, fees, tx_count, blk_count, no, start_time, end_time) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from epoch WHERE no IN ($SELECT_BLOCK_EPOCH)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping epoch_stakes" >> $OUT_FILE;
echo "ALTER TABLE public.epoch_stake DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.epoch_stake (id, addr_id, pool_id, amount, epoch_no) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from epoch_stake WHERE epoch_no IN ($SELECT_BLOCK_EPOCH)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping ada_pots" >> $OUT_FILE;
echo "ALTER TABLE public.ada_pots DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.ada_pots (id, slot_no, epoch_no, treasury, reserves, rewards, utxo, deposits, fees, block_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from ada_pots WHERE epoch_no IN ($SELECT_BLOCK_EPOCH)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping slot leaders" >> $OUT_FILE;
echo "ALTER TABLE public.slot_leader DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.slot_leader (id, hash, pool_hash_id, description) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from slot_leader WHERE id IN (SELECT slot_leader_id FROM block WHERE block_no IN($BLOCKS_TO_EXPORT))) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping multi assets mint" >> $OUT_FILE;
echo "ALTER TABLE public.ma_tx_mint DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.ma_tx_mint (id, quantity, tx_id, ident) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from ma_tx_mint WHERE tx_id IN ($SELECT_TX_ID)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping tx redeemer" >> $OUT_FILE;
echo "ALTER TABLE public.redeemer DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.redeemer (id, tx_id, unit_mem, unit_steps, fee, purpose, index, script_hash, datum_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from redeemer WHERE tx_id IN ($SELECT_TX_ID)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping tx collateral inputs" >> $OUT_FILE;
echo "ALTER TABLE public.collateral_tx_in DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.collateral_tx_in (id, tx_in_id, tx_out_id, tx_out_index) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from collateral_tx_in WHERE tx_in_id IN ($SELECT_TX_ID)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping treasury" >> $OUT_FILE;
echo "ALTER TABLE public.treasury DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.treasury (id, addr_id, cert_index, amount, tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from treasury WHERE tx_id IN ($SELECT_TX_ID)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

echo "-- Dumping reserve" >> $OUT_FILE;
echo "ALTER TABLE public.reserve DISABLE TRIGGER ALL;" >> $OUT_FILE;
echo 'COPY public.reserve (id, addr_id, cert_index, amount, tx_id) FROM stdin WITH CSV;' >> $OUT_FILE;
psql -c "\copy (SELECT * from reserve WHERE tx_id IN ($SELECT_TX_ID)) to STDOUT WITH CSV" $DB >> $OUT_FILE;
echo "\." >> $OUT_FILE;

tar -cf $TAR_FILE $OUT_FILE;