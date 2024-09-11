export const DB_MAX_SAFE_INTEGER = 2_147_483_647;

const selectTxInput = (collateral?: boolean) => `
	SELECT
		tx_in.id AS id,
		tx_out.address AS address,
		tx_in.tx_out_index AS "index",
		tx.hash AS tx_input_id,
		source_tx.hash AS tx_source_id
	FROM tx_out
	JOIN ${collateral ? 'collateral_tx_in' : 'tx_in'} AS tx_in 
		ON tx_out.tx_id = tx_in.tx_out_id
	JOIN tx ON tx.id = tx_in.tx_in_id
	AND tx_in.tx_out_index = tx_out.index
	JOIN tx AS source_tx
  		ON tx_out.tx_id = source_tx.id`;

const selectTxOutput = (collateral = false) => `
	SELECT
		tx_out.id AS id,
		tx_out.address AS address,
		tx_out."index" AS "index",
		tx_out.value AS coin_value,
		tx_out.data_hash AS datum,
		tx_out.reference_script_id as reference_script_id,
		tx.hash AS tx_id
	FROM ${collateral ? 'collateral_tx_out' : 'tx_out'} AS tx_out 
	JOIN tx ON tx_out.tx_id = tx.id`;

export const findTxInputsByIds = `
  	${selectTxInput()}
  	WHERE tx.id = ANY($1)
	ORDER BY tx_in.id ASC`;

export const findTxCollateralsByIds = `
	${selectTxInput(true)}
	WHERE tx.id = ANY($1)
	ORDER BY tx_in.id ASC`;

export const findTxInputsByAddresses = `
  ${selectTxInput()}
	JOIN block ON tx.block_id = block.id
  WHERE tx_out.address = ANY($1)
	AND block.block_no >= $2
	AND block.block_no <= $3
	ORDER BY tx_in.id ASC`;

export const findTxOutputsByIds = `
  	${selectTxOutput()}
  	WHERE tx.id = ANY($1)
	ORDER BY tx_out.id ASC`;

export const findTxOutputsByAddresses = `
  ${selectTxOutput()}
	JOIN block ON tx.block_id = block.id
  WHERE tx_out.address = ANY($1)
	AND block.block_no >= $2
	AND block.block_no <= $3
	ORDER BY tx_out.id ASC`;

export const findCollateralOutputsByTxIds = `
	${selectTxOutput(true)}
	WHERE tx.id = ANY($1)
  ORDER BY tx_out.id ASC`;

export const findTip = `
	SELECT 
		block_no,
		hash,
		slot_no
	FROM block
	ORDER BY block.id DESC
	LIMIT 1`;

export const findBlocksByHashes = `
	SELECT
		block.hash AS hash,
		block.block_no AS block_no,
		block.slot_no AS slot_no,
		block.epoch_no AS epoch_no,
		block.epoch_slot_no AS epoch_slot_no,
		block."size" AS "size",
		block."time" AT TIME ZONE 'UTC' AS "time",
		leader.hash AS slot_leader_hash,
		pool."view" AS slot_leader_pool,
		block.tx_count AS tx_count,
		block.vrf_key AS vrf,
		next_blk.hash AS next_block,
		prev_blk.hash AS previous_block
	FROM block 
	JOIN slot_leader AS leader ON leader.id = block.slot_leader_id
	LEFT JOIN block AS next_blk ON block.id = next_blk.previous_id
	LEFT JOIN block AS prev_blk ON block.previous_id = prev_blk.id
	LEFT JOIN pool_hash AS pool ON pool.id = leader.pool_hash_id
	WHERE block.hash = ANY($1)
	ORDER BY block.id ASC`;

export const findBlocksOutputByHashes = `
	SELECT
		SUM(fee) AS fee,
		SUM(out_sum) AS out_sum,
		block.hash AS hash	
	FROM tx
	JOIN block ON block.id = tx.block_id
	WHERE block.hash = ANY($1)
	GROUP BY block.hash, block.id
	ORDER BY block.id ASC`;

export const findMultiAssetByTxOut = `
	SELECT 
		ma_out.quantity AS quantity,
		ma_id.fingerprint AS fingerprint,
		ma_id."name" AS asset_name,
		ma_id."policy" AS policy_id,
		tx.hash AS tx_id,
		tx_out.id AS tx_out_id
	FROM ma_tx_out AS ma_out
	JOIN multi_asset AS ma_id ON ma_out.ident = ma_id.id
	JOIN tx_out ON tx_out.id = ma_out.tx_out_id
	JOIN tx ON tx_out.tx_id = tx.id
	WHERE tx_out.id = ANY($1)
	ORDER BY ma_out.id ASC`;

export const findReferenceScriptsById = `
	SELECT 
		script.type AS type,
		script.bytes AS bytes,
		script.serialised_size AS serialized_size
	FROM script AS script
	WHERE id = ANY($1)`;

export const findTxMintByIds = `
	SELECT 
		mint.quantity AS quantity,
		ma_id.fingerprint AS fingerprint,
		ma_id."name" AS asset_name,
		ma_id."policy" AS policy_id,
		tx.hash AS tx_id
	FROM ma_tx_mint AS mint
	JOIN multi_asset AS ma_id ON mint.ident = ma_id.id
	JOIN tx ON tx.id = mint.tx_id
	WHERE tx.id = ANY($1)
	ORDER BY mint.id ASC`;

export const findTransactionsByIds = `
	SELECT 
		tx.hash AS id,
		tx.block_index AS "index",
		tx."size" AS "size",
		tx.fee AS fee,
		tx.invalid_before AS invalid_before,
		tx.invalid_hereafter AS invalid_hereafter,
		tx.valid_contract AS valid_contract,
		block.block_no AS block_no,
		block.hash AS block_hash,
		block.slot_no AS block_slot_no
	FROM tx
	JOIN block ON tx.block_id = block.id
  WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC`;

export const findTxRecordIdsByTxHashes = `
	SELECT id FROM tx WHERE hash = ANY($1)	
`;

export const findWithdrawalsByTxIds = `
	SELECT
		withdrawal.amount AS quantity,
		tx.hash AS tx_id,
		stk_addr."view" AS stake_address
	FROM withdrawal
	JOIN tx ON tx.id = withdrawal.tx_id
	JOIN stake_address AS stk_addr ON stk_addr.id = withdrawal.addr_id
	WHERE tx.id = ANY($1)
	ORDER BY withdrawal.id ASC`;

export const findRedeemersByTxIds = `
	SELECT
		redeemer."index" AS "index",
		redeemer.purpose AS purpose,
		redeemer.script_hash AS script_hash,
		redeemer.unit_mem AS unit_mem,
		redeemer.unit_steps AS unit_steps,
		tx.hash AS tx_id
	FROM redeemer
	JOIN tx ON tx.id = redeemer.tx_id
	WHERE tx.id = ANY($1)
	ORDER BY redeemer.id ASC`;

export const findVotingProceduresByTxIds = `
	SELECT
		tx.hash AS tx_id,
		voter_role,
		ch.raw AS committee_voter,
		ch.has_script AS committee_has_script,
		dh.raw AS drep_voter,
		dh.has_script AS drep_has_script,
		ph.hash_raw as pool_voter,
		tx2.hash AS governance_action_tx_id,
		ga.index::INTEGER AS governance_action_index,
		CASE
			WHEN vote = 'No' THEN 0
			WHEN vote = 'Yes' THEN 1
			WHEN vote = 'Abstain' THEN 2
		END AS vote,
		va.url,
		va.data_hash
	FROM tx
	JOIN voting_procedure AS vp ON vp.tx_id = tx.id
	JOIN gov_action_proposal AS ga ON gov_action_proposal_id = ga.id
	JOIN tx AS tx2 ON ga.tx_id = tx2.id
	LEFT JOIN drep_hash AS dh ON drep_voter = dh.id
	LEFT JOIN pool_hash AS ph ON pool_voter = ph.id
	LEFT JOIN voting_anchor AS va ON vp.voting_anchor_id = va.id
	LEFT JOIN committee_hash AS ch ON ch.id = committee_voter
	WHERE tx.id = ANY($1)
	ORDER BY vp.index`;

// LW-9675
export const findProposalProceduresByTxIds = `
	SELECT
		tx.hash AS tx_id,
		ga.deposit,
		ga.description,
		va.url,
		va.data_hash,
		sa.view,
		quorum_numerator AS numerator,
		quorum_denominator AS denominator
	FROM tx
	JOIN gov_action_proposal AS ga ON tx.id = ga.tx_id
	JOIN voting_anchor AS va ON voting_anchor_id = va.id
	JOIN stake_address AS sa ON ga.return_address = sa.id
	LEFT JOIN new_committee AS nc ON gov_action_proposal_id = ga.id
	WHERE tx.id = ANY($1)
	ORDER BY ga.index`;

export const findPoolRetireCertsTxIds = `
	SELECT
		cert.cert_index AS cert_index,
		cert.retiring_epoch AS retiring_epoch,
		pool."view" AS pool_id,
		tx.hash AS tx_id
	FROM tx
	JOIN pool_retire AS cert ON cert.announced_tx_id = tx.id
	JOIN pool_hash AS pool ON pool.id = cert.hash_id
	WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC`;

export const findPoolRegisterCertsByTxIds = `
	SELECT
		cert.cert_index AS cert_index,
		pool.view AS pool_id,
		tx.hash AS tx_id,
		CASE
			WHEN cert.deposit IS NULL THEN '0'
			ELSE cert.deposit
		END AS deposit,
		stake_address.view AS reward_account,
		pledge,
		fixed_cost,
		margin,
		vrf_key_hash
	FROM tx
	JOIN pool_update AS cert ON cert.registered_tx_id = tx.id
	JOIN pool_hash AS pool ON pool.id = cert.hash_id
	JOIN stake_address ON stake_address.id = reward_addr_id
	WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC`;

export const findMirCertsByTxIds = `
	(SELECT
		cert.cert_index AS cert_index,
		cert.amount AS amount,
		'reserve' AS pot,
		addr."view" AS address,
		tx.hash AS tx_id
	FROM tx
	JOIN reserve AS cert ON cert.tx_id = tx.id
	JOIN stake_address AS addr ON cert.addr_id = addr.id
	WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC)
	UNION
	(SELECT
		cert.cert_index AS cert_index,
		cert.amount AS amount,
		'treasury' AS pot,
		addr."view" AS address,
		tx.hash AS tx_id
	FROM tx
	JOIN treasury AS cert ON cert.tx_id = tx.id
	JOIN stake_address AS addr ON cert.addr_id = addr.id
	WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC)`;

export const findStakeCertsByTxIds = `
	(SELECT 
		cert.cert_index AS cert_index,
		addr."view" AS address,
		TRUE AS registration,
		tx.hash AS tx_id,
		cert.deposit AS deposit
	FROM tx
	JOIN stake_registration AS cert ON cert.tx_id = tx.id
	JOIN stake_address AS addr ON addr.id = cert.addr_id
	WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC)
	UNION
	(SELECT 
		cert.cert_index AS cert_index,
		addr."view" AS address,
		FALSE AS registration,
		tx.hash AS tx_id,
		(SELECT sr.deposit FROM stake_registration AS sr
			WHERE sr.addr_id = cert.addr_id
				AND sr.tx_id < tx.id
			ORDER BY sr.tx_id DESC
			LIMIT 1
		) AS deposit
	FROM tx
	JOIN stake_deregistration AS cert ON cert.tx_id = tx.id
	JOIN stake_address AS addr ON addr.id = cert.addr_id
	WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC)`;

export const findDelegationCertsByTxIds = `
	SELECT 
		cert.cert_index AS cert_index,
		tx.hash AS tx_id,
		pool."view" AS pool_id,
		addr."view" AS address
	FROM tx
	JOIN delegation AS cert ON cert.tx_id = tx.id
	JOIN pool_hash AS pool ON pool.id = cert.pool_hash_id
	JOIN stake_address AS addr ON addr.id = cert.addr_id
	WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC`;

export const findDrepCertsByTxIds = `
	SELECT
		cert_index,
		tx.hash AS tx_id,
		has_script,
		drep.raw AS drep_hash,
		url,
		data_hash,
		cert.deposit
	FROM tx
	JOIN drep_registration AS cert ON cert.tx_id = tx.id
	JOIN drep_hash AS drep ON drep.id = cert.drep_hash_id
	LEFT JOIN voting_anchor AS anchor ON anchor.id = voting_anchor_id
	WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC`;

export const findVoteDelegationCertsByTxIds = `
	SELECT
		cert_index,
		tx.hash AS tx_id,
		has_script,
		drep.raw AS drep_hash,
		drep.view AS drep_view,
		addr.view AS address
	FROM tx
	JOIN delegation_vote AS cert ON cert.tx_id = tx.id
	JOIN drep_hash AS drep ON drep.id = cert.drep_hash_id
	JOIN stake_address AS addr ON addr.id = cert.addr_id
	WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC`;

export const findCommitteeRegistrationByTxIds = `
	SELECT
		cert_index,
		tx.hash AS tx_id,
		ch1.raw AS cold_key,
		ch1.has_script AS cold_key_has_script,
		ch2.raw AS hot_key,
		ch2.has_script AS hot_key_has_script
	FROM tx
	JOIN committee_registration AS cert ON cert.tx_id = tx.id
	JOIN committee_hash AS ch1 ON cold_key_id = ch1.id
	JOIN committee_hash AS ch2 ON hot_key_id = ch2.id
	WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC`;

export const findCommitteeResignByTxIds = `
	SELECT
		cert_index,
		tx.hash AS tx_id,
		ch.raw AS cold_key,
		ch.has_script AS cold_key_has_script,
		url,
		data_hash
	FROM tx
	JOIN committee_de_registration AS cert ON cert.tx_id = tx.id
	JOIN committee_hash AS ch ON cold_key_id = ch.id
	LEFT JOIN voting_anchor AS anchor ON anchor.id = voting_anchor_id
	WHERE tx.id = ANY($1)
	ORDER BY tx.id ASC`;

export const findTxsByAddresses = {
  ORDER: `
ORDER BY tx_id`,
  SELECT: `
SELECT
  DISTINCT tx_id`,
  WITH: `
WITH source AS (
  SELECT tx_id, tx_in_id FROM tx_out
  LEFT JOIN tx_in ON tx_out_id = tx_id AND tx_out_index = index
  WHERE address = ANY($1)
),
combined AS (
  SELECT tx_id FROM source
  UNION ALL
  SELECT tx_in_id AS tx_id FROM source WHERE tx_in_id IS NOT NULL
)`,
  withRange: {
    FROM: `
FROM partial
JOIN tx ON
  tx.id = tx_id
JOIN block ON
  block.id = block_id AND
  block_no BETWEEN $2 AND $3`,
    WITH: `,
partial AS (
  SELECT
    DISTINCT tx_id
  FROM combined
)`
  },
  withoutRange: {
    FROM: `
FROM combined`,
    WITH: ''
  }
} as const;
