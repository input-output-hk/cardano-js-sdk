import { Cardano, NetworkInfo, ProviderError, ProviderFailure, TimeSettings } from '@cardano-sdk/core';
import { GenesisData } from './types';
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

export const loadGenesisData = async (cardanoNodeConfigPath: string): Promise<GenesisData> => {
  try {
    const genesisFilePath = require(path.resolve(cardanoNodeConfigPath)).ShelleyGenesisFile;
    const genesis = JSONbig({ useNativeBigInt: true }).parse(
      fs.readFileSync(path.resolve(path.dirname(cardanoNodeConfigPath), genesisFilePath), 'utf-8')
    );
    return {
      maxLovelaceSupply: genesis.maxLovelaceSupply,
      networkId: genesis.networkId,
      networkMagic: genesis.networkMagic
    };
  } catch (error) {
    throw new ProviderError(ProviderFailure.Unhealthy, error);
  }
};
