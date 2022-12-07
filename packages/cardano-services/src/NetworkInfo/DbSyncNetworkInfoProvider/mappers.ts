import { Cardano, ProviderError, ProviderFailure, SupplySummary } from '@cardano-sdk/core';
import { CostModelsParamModel, GenesisData, ProtocolParamsModel } from './types';
import { LedgerTipModel } from '../../util/DbSyncProvider';
import JSONbig from 'json-bigint';
import fs from 'fs';
import path from 'path';

interface ToLovalaceSupplyInput {
  circulatingSupply: string;
  totalSupply: string;
}

export const networkIdMap = {
  Mainnet: Cardano.NetworkId.mainnet,
  Testnet: Cardano.NetworkId.testnet
};

export const toSupply = ({ circulatingSupply, totalSupply }: ToLovalaceSupplyInput): SupplySummary => ({
  circulating: BigInt(circulatingSupply),
  total: BigInt(totalSupply)
});

export const toLedgerTip = ({ block_no, slot_no, hash }: LedgerTipModel): Cardano.Tip => ({
  blockNo: Cardano.BlockNo(Number(block_no)),
  hash: Cardano.BlockId(hash.toString('hex')),
  slot: Cardano.Slot(Number(slot_no))
});

export const mapCostModels = (costs: CostModelsParamModel | null) => {
  const models: Cardano.CostModels = [];
  if (costs?.PlutusV1) models[Cardano.PlutusLanguageVersion.V1] = costs.PlutusV1;
  if (costs?.PlutusV2) models[Cardano.PlutusLanguageVersion.V2] = costs.PlutusV2;
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
  decentralisation,
  collateral_percent,
  price_mem,
  price_step,
  max_tx_ex_mem,
  max_tx_ex_steps,
  max_block_ex_mem,
  max_block_ex_steps,
  max_epoch,
  costs
}: ProtocolParamsModel): Cardano.ProtocolParameters => ({
  coinsPerUtxoByte: Number(coins_per_utxo_size),
  collateralPercentage: collateral_percent,
  costModels: mapCostModels(costs),
  decentralizationParameter: String(decentralisation),
  desiredNumberOfPools: optimal_pool_count,
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
  minFeeCoefficient: min_fee_a,
  minFeeConstant: min_fee_b,
  minPoolCost: Number(min_pool_cost),
  monetaryExpansion: String(monetary_expand_rate),
  poolDeposit: Number(pool_deposit),
  poolInfluence: String(influence),
  poolRetirementEpochBound: max_epoch,
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
  systemStart: new Date(genesis.systemStart)
});

export const loadGenesisData = async (cardanoNodeConfigPath: string): Promise<GenesisData> => {
  try {
    const genesisFilePath = require(path.resolve(cardanoNodeConfigPath)).ShelleyGenesisFile;
    const genesis = JSONbig({ useNativeBigInt: true }).parse(
      fs.readFileSync(path.resolve(path.dirname(cardanoNodeConfigPath), genesisFilePath), 'utf-8')
    );

    return {
      activeSlotsCoefficient: genesis.activeSlotsCoeff,
      epochLength: genesis.epochLength,
      maxKesEvolutions: genesis.maxKESEvolutions,
      maxLovelaceSupply: genesis.maxLovelaceSupply,
      networkId: genesis.networkId,
      networkMagic: genesis.networkMagic,
      securityParameter: genesis.securityParam,
      slotLength: genesis.slotLength,
      slotsPerKesPeriod: genesis.slotsPerKESPeriod,
      systemStart: genesis.systemStart,
      updateQuorum: genesis.updateQuorum
    };
  } catch (error) {
    throw new ProviderError(ProviderFailure.Unhealthy, error);
  }
};
