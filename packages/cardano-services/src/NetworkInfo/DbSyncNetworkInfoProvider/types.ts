import { Cardano } from '@cardano-sdk/core';

export interface CirculatingSupplyModel {
  circulating_supply: string;
}

export interface TotalSupplyModel {
  total_supply: string;
}

export interface ActiveStakeModel {
  active_stake: string;
}

export interface LiveStakeModel {
  live_stake: string;
}

export interface EpochModel {
  no: number;
}

export interface CostModelsParamModel {
  PlutusV1?: Cardano.CostModel;
  PlutusV2?: Cardano.CostModel;
  PlutusV3?: Cardano.CostModel;
}

export interface ProtocolParamsModel {
  coins_per_utxo_size: string;
  max_tx_size: number;
  max_val_size: string;
  min_pool_cost: string;
  key_deposit: string;
  pool_deposit: string;
  protocol_major: number;
  protocol_minor: number;
  min_fee_a: number;
  min_fee_b: number;
  max_collateral_inputs: number;
  max_block_size: number;
  max_bh_size: number;
  optimal_pool_count: number;
  influence: number;
  min_fee_ref_script_cost_per_byte: number;
  monetary_expand_rate: number;
  treasury_growth_rate: number;
  decentralisation: number;
  collateral_percent: number;
  price_mem: number;
  price_step: number;
  max_tx_ex_mem: string;
  max_tx_ex_steps: string;
  max_block_ex_mem: string;
  max_block_ex_steps: string;
  max_epoch: number;
  costs: CostModelsParamModel | null;
  committee_min_size: number;
  committee_max_term_length: number;
  gov_action_lifetime: number;
  gov_action_deposit: number;
  drep_deposit: number;
  drep_activity: number;
  pvt_motion_no_confidence: number;
  pvt_committee_normal: number;
  pvt_committee_no_confidence: number;
  pvt_hard_fork_initiation: number;
  pvtpp_security_group: number;
  dvt_motion_no_confidence: number;
  dvt_committee_normal: number;
  dvt_committee_no_confidence: number;
  dvt_update_to_constitution: number;
  dvt_hard_fork_initiation: number;
  dvt_p_p_network_group: number;
  dvt_p_p_economic_group: number;
  dvt_p_p_technical_group: number;
  dvt_p_p_gov_group: number;
  dvt_treasury_withdrawal: number;
}
