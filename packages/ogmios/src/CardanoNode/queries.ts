import * as CardanoNodeUtil from './errorUtils.js';
import { CardanoNodeErrors } from '@cardano-sdk/core';
import { eraSummary, genesis } from '../ogmiosToCore/index.js';
import type { Logger } from 'ts-log';
import type { StateQueryClient } from '@cardano-ogmios/client/dist/StateQuery';

const wrapError = async <T>(query: () => Promise<T>) => {
  try {
    return await query();
  } catch (error) {
    throw CardanoNodeUtil.asCardanoNodeError(error) || new CardanoNodeErrors.UnknownCardanoNodeError(error);
  }
};

export const queryEraSummaries = (client: StateQueryClient, logger: Logger) =>
  wrapError(async () => {
    logger.info('Querying era summaries');
    const systemStart = await client.systemStart();
    const eraSummaries = await client.eraSummaries();
    return eraSummaries.map((era) => eraSummary(era, systemStart));
  });

export const queryGenesisParameters = (client: StateQueryClient, logger: Logger) =>
  wrapError(async () => {
    logger.info('Querying genesis parameters');
    return genesis(await client.genesisConfig());
  });
