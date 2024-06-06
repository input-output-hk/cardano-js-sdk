import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import JSONbig from 'json-bigint';
import fs from 'fs';
import path from 'path';
import type { GenesisData } from '../types.js';

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
