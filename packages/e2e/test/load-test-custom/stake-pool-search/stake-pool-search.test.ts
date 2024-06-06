import * as envalid from 'envalid';
import { Cardano } from '@cardano-sdk/core';
import { MeasurementUtil, getEnv, getLoadTestScheduler } from '../../../src/index.js';
import { bufferTime, from, tap } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';
import { stakePoolHttpProvider } from '@cardano-sdk/cardano-services-client';
import type { Logger } from 'ts-log';
import type { QueryStakePoolsArgs } from '@cardano-sdk/core';

// Example call:
/* STAKE_POOL_PROVIDER_URL="http://mhvm:4000/stake-pool" \
   VIRTUAL_USERS_GENERATE_DURATION=100 \
   VIRTUAL_USERS_COUNT=5000 \
   yarn load-test-custom:stake-pool-query
*/

const { STAKE_POOL_PROVIDER_URL } = envalid.cleanEnv(process.env, { STAKE_POOL_PROVIDER_URL: envalid.str() });
const provider = stakePoolHttpProvider({ baseUrl: STAKE_POOL_PROVIDER_URL, logger });
const testLogger: Logger = console;
const intermediateResultsInterval = 10_000;

const { VIRTUAL_USERS_GENERATE_DURATION: duration, VIRTUAL_USERS_COUNT: callsPerDuration } = getEnv([
  'VIRTUAL_USERS_GENERATE_DURATION',
  'VIRTUAL_USERS_COUNT'
]);

enum MeasureTarget {
  healthCheckUnhealthy = 'healthCheckUnhealthy',
  healthCheckError = 'healthCheckError',
  queryFirstUser = 'queryFirstUser',
  queryNoFilters = 'queryNoFilters',
  queryNoFiltersErr = 'queryNoFiltersErr',
  queryWithStatus = 'queryWithStatus',
  queryWithStatusErr = 'queryWithStatusErr',
  queryWithId = 'queryWithId',
  queryWithIdErr = 'queryWithIdErr',
  queryWithStatusAndId = 'queryWithStatusAndId',
  queryWithStatusAndIdErr = 'queryWithStatusAndIdErr'
}

const PAGE_SIZE = 20;

/** The set of pools id found while getting results */
const poolIds: Cardano.PoolId[] = [];

const measurement = new MeasurementUtil<MeasureTarget | string>();

const healthCheck = async (id: number): Promise<boolean> => {
  try {
    const result = await provider.healthCheck();

    if (result.ok) return true;

    measurement.addStartMarker(MeasureTarget.healthCheckUnhealthy, id);
    logger.warn('Not ok healthCheck result', result);
  } catch (error) {
    measurement.addStartMarker(MeasureTarget.healthCheckError, id);
    logger.error('Error thrown while performing healthCheck', error);
  }

  return false;
};

const randomizeFilter = () => {
  const filters: NonNullable<QueryStakePoolsArgs['filters']> = {};

  // Apply a random filter to 80% of the remaining users in the list, or if it's empty.
  if (poolIds.length === 0 || Math.random() > 0.2) {
    filters.status = [
      [
        Cardano.StakePoolStatus.Activating,
        Cardano.StakePoolStatus.Active,
        Cardano.StakePoolStatus.Retired,
        Cardano.StakePoolStatus.Retiring
      ][Math.floor(Math.random() * 4)]
    ];
  }

  // We can't perform calls with id until we have some ids;
  // when we have at least one id, we want to perform 80% calls with id and 20% without
  if (poolIds.length > 0 && Math.random() > 0.2) {
    // If we have data to randomize: let's do it
    filters.identifier = {
      values: [{ id: poolIds[Math.floor(Math.random() * poolIds.length)] }]
    };
  }

  return filters;
};

/**
 * Gets the name of the stat to measure depending on the filter this user is using to perform the query
 *
 * @param isFirstUser First user is the one which does initial query for cache priming.
 * @returns the name of the stat we are measuring
 */
const getStatName = (
  isFirstUser: boolean,
  filters: QueryStakePoolsArgs['filters']
): { statName: MeasureTarget; errorStatName?: MeasureTarget } => {
  if (isFirstUser) return { statName: MeasureTarget.queryFirstUser };

  const { identifier, status } = filters!;
  if (identifier && status)
    return { errorStatName: MeasureTarget.queryWithStatusAndIdErr, statName: MeasureTarget.queryWithStatusAndId };
  if (identifier) return { errorStatName: MeasureTarget.queryWithIdErr, statName: MeasureTarget.queryWithId };
  if (status) return { errorStatName: MeasureTarget.queryWithStatusErr, statName: MeasureTarget.queryWithStatus };
  return { errorStatName: MeasureTarget.queryNoFiltersErr, statName: MeasureTarget.queryNoFilters };
};

const performQuery = async (id: number, isFirstUser: boolean): Promise<void> => {
  const healthy = await healthCheck(id);
  if (!healthy) return;

  const args: QueryStakePoolsArgs = { pagination: { limit: PAGE_SIZE, startAt: 0 } };

  if (!isFirstUser) {
    args.filters = randomizeFilter();
  }

  let receivedResultsCount = 0;
  do {
    const { statName, errorStatName } = getStatName(isFirstUser, args.filters);
    try {
      measurement.addStartMarker(statName, id);
      const result = await provider.queryStakePools(args);

      receivedResultsCount = result.pageResults.length;

      // Take ids to randomize next requests
      for (const pool of result.pageResults) poolIds.push(pool.id);

      measurement.addMeasureMarker(statName, id);
    } catch (error) {
      errorStatName && measurement.addStartMarker(errorStatName, id);
      testLogger.error(error);
      return;
    }

    args.pagination.startAt += PAGE_SIZE;
  } while (PAGE_SIZE === receivedResultsCount);
};

measurement.start();

const showResults = () => {
  const results = measurement.getMeasurements([
    MeasureTarget.healthCheckError,
    MeasureTarget.healthCheckUnhealthy,
    MeasureTarget.queryFirstUser,
    MeasureTarget.queryNoFilters,
    MeasureTarget.queryNoFiltersErr,
    MeasureTarget.queryWithId,
    MeasureTarget.queryWithIdErr,
    MeasureTarget.queryWithStatus,
    MeasureTarget.queryWithStatusErr,
    MeasureTarget.queryWithStatusAndId,
    MeasureTarget.queryWithStatusAndIdErr
  ]);

  testLogger.info('Measurements:', results);
};

getLoadTestScheduler<void>(
  { callUnderTest: (id) => from(performQuery(id, id === 0)), callsPerDuration, duration },
  { logger: testLogger }
)
  .pipe(
    bufferTime(intermediateResultsInterval),
    tap(() => {
      testLogger.info(`\nPartial results every ${intermediateResultsInterval}ms:`);
      showResults();
    })
  )
  .subscribe({
    complete: () => {
      testLogger.info('--------- Final results -----------------');
      showResults();
    }
  });
