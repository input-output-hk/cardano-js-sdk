import { CardanoNodeErrors, CardanoNodeUtil } from '@cardano-sdk/core';

import { LedgerStateQuery } from '@cardano-ogmios/client';
import { Logger } from 'ts-log';
import { eraSummary, genesis } from '../ogmiosToCore';

const wrapError = async <T>(query: () => Promise<T>) => {
  try {
    return await query();
  } catch (error) {
    throw CardanoNodeUtil.asCardanoNodeError(error) || new CardanoNodeErrors.UnknownCardanoNodeError(error);
  }
};

export const queryEraSummaries = (client: LedgerStateQuery.LedgerStateQueryClient, logger: Logger) =>
  wrapError(async () => {
    logger.info('Querying era summaries');
    const systemStart = new Date((await client.eraStart()).time);
    const eraSummaries = await client.eraSummaries();
    return eraSummaries.map((era) => eraSummary(era, systemStart));
  });

export const queryGenesisParameters = (client: LedgerStateQuery.LedgerStateQueryClient, logger: Logger) =>
  wrapError(async () => {
    logger.info('Querying genesis parameters');
    // REVIEW: The queryNetwork/genesis local-state-query now expects one era as argument (either 'byron', 'shelley' or 'alonzo')
    // to retrieve the corresponding genesis configuration.
    // 'shelley' genesis maps best to the compact genesis we're using
    return genesis(await client.genesisConfiguration('shelley'));
  });
