/* eslint-disable complexity */
import { Cardano, Seconds, SupplySummary } from '@cardano-sdk/core';
import { CostModelsParamModel, ProtocolParamsModel } from './types';
import { GenesisData } from '../../types';
import { LedgerTipModel } from '../../util/DbSyncProvider';

interface ToLovalaceSupplyInput {
  circulatingSupply: string;
  totalSupply: string;
}

export const networkIdMap = {
  Mainnet: Cardano.NetworkId.Mainnet,
  Testnet: Cardano.NetworkId.Testnet
};

export const toSupply = ({ circulatingSupply, totalSupply }: ToLovalaceSupplyInput): SupplySummary => ({
  circulating: BigInt(circulatingSupply),
  total: BigInt(totalSupply)
});

export const toLedgerTip = ({ block_no, slot_no, hash }: LedgerTipModel): Cardano.Tip => ({
  blockNo: Cardano.BlockNo(Number(block_no)),
  hash: hash.toString('hex') as unknown as Cardano.BlockId,
  slot: Cardano.Slot(Number(slot_no))
});

export const mapCostModels = (costs: CostModelsParamModel | null) => {
  const models: Cardano.CostModels = new Map();
  if (costs?.PlutusV1) models.set(Cardano.PlutusLanguageVersion.V1, costs.PlutusV1);
  if (costs?.PlutusV2) models.set(Cardano.PlutusLanguageVersion.V2, costs.PlutusV2);
  if (costs?.PlutusV3) models.set(Cardano.PlutusLanguageVersion.V3, costs.PlutusV3);
  return models;
};

export const toProtocolParams = ({
  coins_per_utxo_size,
  max_tx_size,
  max_val_size,
  max_collateral_inputs,
  min_pool_cost,
  pool_deposit,
  key_deposit,
  protocol_major,
  protocol_minor,
  min_fee_a,
  min_fee_b,
  max_block_size,
  max_bh_size,
  optimal_pool_count,
  influence,
  monetary_expand_rate,
  treasury_growth_rate,
  collateral_percent,
  price_mem,
  price_step,
  max_tx_ex_mem,
  max_tx_ex_steps,
  max_block_ex_mem,
  max_block_ex_steps,
  max_epoch,
  costs,
  pvt_motion_no_confidence,
  pvt_committee_normal,
  pvt_committee_no_confidence,
  pvt_hard_fork_initiation,
  pvtpp_security_group,
  dvt_motion_no_confidence,
  dvt_committee_normal,
  dvt_committee_no_confidence,
  dvt_update_to_constitution,
  dvt_hard_fork_initiation,
  dvt_p_p_network_group,
  dvt_p_p_economic_group,
  dvt_p_p_technical_group,
  dvt_p_p_gov_group,
  dvt_treasury_withdrawal,
  committee_min_size,
  committee_max_term_length,
  gov_action_lifetime,
  gov_action_deposit,
  drep_deposit,
  drep_activity,
  min_fee_ref_script_cost_per_byte
}: ProtocolParamsModel): Cardano.ProtocolParameters => ({
  coinsPerUtxoByte: Number(coins_per_utxo_size),
  collateralPercentage: collateral_percent,
  ...(committee_max_term_length && { committeeTermLimit: Cardano.EpochNo(committee_max_term_length) }),
  costModels: mapCostModels(costs),
  dRepDeposit: Number(drep_deposit),
  // CDDL represents it as `32: epoch  ; DRep inactivity period`
  ...(drep_activity && { dRepInactivityPeriod: Cardano.EpochNo(drep_activity) }),
  ...(dvt_committee_no_confidence &&
    dvt_committee_normal &&
    dvt_hard_fork_initiation &&
    dvt_motion_no_confidence &&
    dvt_p_p_economic_group &&
    dvt_p_p_gov_group &&
    dvt_p_p_network_group &&
    dvt_p_p_technical_group &&
    dvt_treasury_withdrawal &&
    dvt_update_to_constitution && {
      dRepVotingThresholds: {
        committeeNoConfidence: Cardano.FractionUtils.toFraction(dvt_committee_no_confidence),
        committeeNormal: Cardano.FractionUtils.toFraction(dvt_committee_normal),
        hardForkInitiation: Cardano.FractionUtils.toFraction(dvt_hard_fork_initiation),
        motionNoConfidence: Cardano.FractionUtils.toFraction(dvt_motion_no_confidence),
        ppEconomicGroup: Cardano.FractionUtils.toFraction(dvt_p_p_economic_group),
        ppGovernanceGroup: Cardano.FractionUtils.toFraction(dvt_p_p_gov_group),
        ppNetworkGroup: Cardano.FractionUtils.toFraction(dvt_p_p_network_group),
        ppTechnicalGroup: Cardano.FractionUtils.toFraction(dvt_p_p_technical_group),
        treasuryWithdrawal: Cardano.FractionUtils.toFraction(dvt_treasury_withdrawal),
        updateConstitution: Cardano.FractionUtils.toFraction(dvt_update_to_constitution)
      }
    }),
  desiredNumberOfPools: optimal_pool_count,
  governanceActionDeposit: Number(gov_action_deposit),
  ...(gov_action_lifetime && { governanceActionValidityPeriod: Cardano.EpochNo(gov_action_lifetime) }),
  maxBlockBodySize: max_block_size,
  maxBlockHeaderSize: max_bh_size,
  maxCollateralInputs: max_collateral_inputs,
  maxExecutionUnitsPerBlock: {
    memory: Number(max_block_ex_mem),
    steps: Number(max_block_ex_steps)
  },
  maxExecutionUnitsPerTransaction: {
    memory: Number(max_tx_ex_mem),
    steps: Number(max_tx_ex_steps)
  },
  maxTxSize: max_tx_size,
  maxValueSize: Number(max_val_size),
  minCommitteeSize: Number(committee_min_size),
  minFeeCoefficient: min_fee_a,
  minFeeConstant: min_fee_b,
  minFeeRefScriptCostPerByte: String(min_fee_ref_script_cost_per_byte),
  minPoolCost: Number(min_pool_cost),
  monetaryExpansion: String(monetary_expand_rate),
  poolDeposit: Number(pool_deposit),
  poolInfluence: String(influence),
  poolRetirementEpochBound: max_epoch,
  ...(pvt_committee_no_confidence &&
    pvt_committee_normal &&
    pvt_hard_fork_initiation &&
    pvt_motion_no_confidence &&
    pvtpp_security_group && {
      poolVotingThresholds: {
        committeeNoConfidence: Cardano.FractionUtils.toFraction(pvt_committee_no_confidence),
        committeeNormal: Cardano.FractionUtils.toFraction(pvt_committee_normal),
        hardForkInitiation: Cardano.FractionUtils.toFraction(pvt_hard_fork_initiation),
        motionNoConfidence: Cardano.FractionUtils.toFraction(pvt_motion_no_confidence),
        securityRelevantParamVotingThreshold: Cardano.FractionUtils.toFraction(pvtpp_security_group)
      }
    }),
  prices: {
    memory: price_mem,
    steps: price_step
  },
  protocolVersion: {
    major: protocol_major,
    minor: protocol_minor
  },
  stakeKeyDeposit: Number(key_deposit),
  treasuryExpansion: String(treasury_growth_rate)
});

export const toGenesisParams = (genesis: GenesisData): Cardano.CompactGenesis => ({
  ...genesis,
  networkId: networkIdMap[genesis.networkId],
  slotLength: Seconds(genesis.slotLength),
  systemStart: new Date(genesis.systemStart)
});
