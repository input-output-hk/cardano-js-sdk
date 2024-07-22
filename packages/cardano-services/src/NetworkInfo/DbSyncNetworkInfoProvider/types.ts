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
  committee_min_size: number | null;
  committee_max_term_length: number | null;
  gov_action_lifetime: number | null;
  gov_action_deposit: number | null;
  drep_deposit: number | null;
  drep_activity: number | null;
  pvt_motion_no_confidence: number | null;
  pvt_committee_normal: number | null;
  pvt_committee_no_confidence: number | null;
  pvt_hard_fork_initiation: number | null;
  pvtpp_security_group: number | null;
  dvt_motion_no_confidence: number | null;
  dvt_committee_normal: number | null;
  dvt_committee_no_confidence: number | null;
  dvt_update_to_constitution: number | null;
  dvt_hard_fork_initiation: number | null;
  dvt_p_p_network_group: number | null;
  dvt_p_p_economic_group: number | null;
  dvt_p_p_technical_group: number | null;
  dvt_p_p_gov_group: number | null;
  dvt_treasury_withdrawal: number | null;
}
