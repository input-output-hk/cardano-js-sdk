export const latestDistinctAddresses = `
  SELECT address, count(*) as tx_count
  FROM tx_out
  GROUP BY address
  ORDER BY TX_COUNT desc
  LIMIT $1`;

export const latestBlockHashes = `
  SELECT hash
  FROM block
  ORDER BY id DESC
  LIMIT $1`;

export const latestTxHashes = `
  SELECT tx.hash as tx_hash
  FROM tx
  ORDER BY id DESC
  LIMIT $1`;

export const beginLatestTxHashes = `
  SELECT tx.hash as tx_hash FROM tx
  JOIN tx_out ON tx_out.tx_id = tx.id`;

export const latestTxHashesWithMultiAsset = `
  JOIN ma_tx_out ON ma_tx_out.tx_out_id = tx_out.id`;

export const latestTxHashesWithAuxiliaryData = `
  JOIN tx_metadata ON tx_metadata.tx_id = tx.id`;

export const latestTxHashesWithMint = `
  JOIN ma_tx_mint ON ma_tx_mint.tx_id = tx.id`;

export const latestTxHashesWithRedeemer = `
  JOIN redeemer ON redeemer.tx_id = tx.id `;

export const latestTxHashesWithCollateral = `
  JOIN collateral_tx_in ON collateral_tx_in.tx_in_id = tx.id`;

export const latestTxHashesWithPoolRetireCerts = `
  JOIN pool_retire ON pool_retire.announced_tx_id = tx.id`;

export const latestTxHashesWithPoolUpdateCerts = `
  JOIN pool_update ON pool_update.registered_tx_id = tx.id`;

export const latestTxHashesWithStakeRegistrationCerts = `
  JOIN stake_registration ON stake_registration.tx_id = tx.id`;

export const latestTxHashesWithStakeDeregistrationCerts = `
  JOIN stake_deregistration ON stake_deregistration.tx_id = tx.id`;

export const latestTxHashesWithDelegationCerts = `
  JOIN delegation ON delegation.tx_id = tx.id`;

export const latestTxHashesWithMirCerts = `
  JOIN reserve ON reserve.tx_id = tx.id`;

export const latestTxHashesWithWithdrawal = `
  JOIN withdrawal ON withdrawal.tx_id = tx.id`;

export const latestTxHashesWithCollateralOutput = `
  JOIN collateral_tx_out ON collateral_tx_out.tx_id = tx.id`;

export const latestTxHashesWithProposalProcedures = `
  JOIN gov_action_proposal ON gov_action_proposal.tx_id = tx.id`;

export const latestTxHashesWithVotingProcedures = `
  JOIN voting_procedure ON voting_procedure.tx_id = tx.id`;

export const latestTxHashesWithScriptReference = `
  JOIN script ON script.tx_id = tx.id
  WHERE tx_out.reference_script_id IS NOT NULL`;

export const endLatestTxHashes = `
  GROUP BY tx.id
  ORDER BY tx.id DESC
  LIMIT $1`;

export const genesisUtxoAddresses = `
  SELECT
   address
  FROM 
  tx_out WHERE
    value = 500000000000
  GROUP BY address
  LIMIT 3`;

export const transactionInBlockRange = `
  SELECT
    address, block_no, tx_id
  FROM tx_out
    JOIN tx ON tx_out.tx_id = tx.id
    JOIN block ON tx.block_id = block.id
    AND block.block_no >= $1
    AND block.block_no <= $2`;

export const findMultiAssetTxOut = `
	SELECT 
		tx_out.id AS tx_out_id
	FROM ma_tx_out AS ma_out
	JOIN multi_asset AS ma_id ON ma_out.ident = ma_id.id
	JOIN tx_out ON tx_out.id = ma_out.tx_out_id
	JOIN tx ON tx_out.tx_id = tx.id
	ORDER BY ma_out.id ASC
  LIMIT $1`;

const Queries = {
  beginLatestTxHashes,
  endLatestTxHashes,
  findMultiAssetTxOut,
  genesisUtxoAddresses,
  latestBlockHashes,
  latestDistinctAddresses,
  latestTxHashes,
  latestTxHashesWithAuxiliaryData,
  latestTxHashesWithCollateral,
  latestTxHashesWithCollateralOutput,
  latestTxHashesWithDelegationCerts,
  latestTxHashesWithMint,
  latestTxHashesWithMirCerts,
  latestTxHashesWithMultiAsset,
  latestTxHashesWithPoolRetireCerts,
  latestTxHashesWithPoolUpdateCerts,
  latestTxHashesWithRedeemer,
  latestTxHashesWithStakeDeregistrationCerts,
  latestTxHashesWithStakeRegistrationCerts,
  latestTxHashesWithWithdrawal,
  transactionInBlockRange
};

export default Queries;
