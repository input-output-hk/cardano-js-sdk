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
  pool_voting_thresholds: Cardano.PoolVotingThresholds;
  drep_voting_thresholds: Cardano.DelegateRepresentativeThresholds;
  min_committee_size: number;
  committee_term_limit: number;
  governance_action_validity_period: number;
  gov_action_deposit: number;
  drep_deposit: number;
  drep_inactivity_period: number;
}
