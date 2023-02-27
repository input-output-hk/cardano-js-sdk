import { CardanoNodeErrors, CardanoNodeUtil } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { StateQueryClient } from '@cardano-ogmios/client/dist/StateQuery';
import { eraSummary, genesis } from '../ogmiosToCore';

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
