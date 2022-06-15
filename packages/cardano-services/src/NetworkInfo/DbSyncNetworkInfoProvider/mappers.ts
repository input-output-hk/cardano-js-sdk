import {
  Cardano,
  NetworkInfo,
  ProtocolParametersRequiredByWallet,
  ProviderError,
  ProviderFailure,
  TimeSettings
} from '@cardano-sdk/core';
import { GenesisData, LedgerTipModel, WalletProtocolParamsModel } from './types';
import JSONbig from 'json-bigint';
import fs from 'fs';
import path from 'path';

interface ToNetworkInfoInput {
  networkMagic: Cardano.NetworkMagic;
  networkId: Cardano.CardanoNetworkId;
  timeSettings: TimeSettings[];
  maxLovelaceSupply: Cardano.Lovelace;
  circulatingSupply: string;
  totalSupply: string;
  activeStake: string;
  liveStake: string;
}

export const networkIdMap = {
  Mainnet: Cardano.NetworkId.mainnet,
  Testnet: Cardano.NetworkId.testnet
};

export const toNetworkInfo = ({
  networkId,
  networkMagic,
  timeSettings,
  circulatingSupply,
  maxLovelaceSupply,
  totalSupply,
  activeStake,
  liveStake
}: ToNetworkInfoInput): NetworkInfo => ({
  lovelaceSupply: {
    circulating: BigInt(circulatingSupply),
    max: maxLovelaceSupply,
    total: BigInt(totalSupply)
  },
  network: {
    id: networkIdMap[networkId],
    magic: networkMagic,
    timeSettings
  },
  stake: {
    active: BigInt(activeStake),
    live: BigInt(liveStake)
  }
});

export const toLedgerTip = ({ block_no, slot_no, hash }: LedgerTipModel): Cardano.Tip => ({
  blockNo: block_no,
  hash: Cardano.BlockId(hash.toString('hex')),
  slot: slot_no
});

export const toWalletProtocolParams = ({
  coins_per_utxo_word,
  max_tx_size,
  max_val_size,
  max_collateral_inputs,
  min_pool_cost,
  pool_deposit,
  key_deposit,
  protocol_major,
  protocol_minor,
  min_fee_a,
  min_fee_b
}: WalletProtocolParamsModel): ProtocolParametersRequiredByWallet => ({
  coinsPerUtxoWord: Number(coins_per_utxo_word),
  maxCollateralInputs: max_collateral_inputs,
  maxTxSize: max_tx_size,
  maxValueSize: Number(max_val_size),
  minFeeCoefficient: min_fee_a,
  minFeeConstant: min_fee_b,
  minPoolCost: Number(min_pool_cost),
  poolDeposit: Number(pool_deposit),
  protocolVersion: {
    major: protocol_major,
    minor: protocol_minor
  },
  stakeKeyDeposit: Number(key_deposit)
});

export const toGenesisParams = (genesis: GenesisData): Cardano.CompactGenesis => ({
  ...genesis,
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
