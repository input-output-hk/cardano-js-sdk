import * as envalid from 'envalid';
import { Cardano } from '@cardano-sdk/core';
import { logger } from '@cardano-sdk/util-dev';
import { stakePoolHttpProvider } from '@cardano-sdk/cardano-services-client';
import type { ArtilleryContext, FunctionHook, WhileTrueHook } from './artillery.js';
import type { Paginated, QueryStakePoolsArgs } from '@cardano-sdk/core';

/**
 * The context variables shared between all the hooks.
 * Hooks must record here the state of the session of current artillery virtual user
 */
interface StakePoolSearchVars extends Paginated<Cardano.StakePool> {
  /** The arguments used for the query; to repeat the same query, but next page, on next iteration */
  args: QueryStakePoolsArgs;

  /** `performQuery()` stores here if it gets an error from the query to let `moreResults()` knows when exit on error */
  gotError?: boolean;

  /** The result of the health check performed at the beginning of virtual user session */
  healthCheckResult: boolean;
}

const env = envalid.cleanEnv(process.env, { STAKE_POOL_PROVIDER_URL: envalid.str() });
const provider = stakePoolHttpProvider({ baseUrl: env.STAKE_POOL_PROVIDER_URL, logger });

const PAGE_SIZE = 20;

/** The set of pools id found while getting results */
const poolIds: Cardano.PoolId[] = [];

/** The artillery uid of the first artillery virtual user. Used to track time of first request to measure cache efficiency */
let firstUser = '';

/**
 * Gets the name of the stat to measure depending on the filter this user is using to perform the query
 *
 * @param ctx the artillery context
 * @returns the name of the stat we are measuring
 */
const getStatName = (ctx: ArtilleryContext<StakePoolSearchVars>) => {
  const { _uid, vars } = ctx;

  if (_uid === firstUser) return 'query.First';

  const { identifier, status } = vars.args.filters!;
  const nameStatId = identifier ? 'id' : '__'; // ATM id is the only identifier used by the test
  const statusStatName = status && status.length > 0 ? 'status' : '______';

  return `query.${nameStatId}_${statusStatName}`;
};

type Filters = NonNullable<QueryStakePoolsArgs['filters']>;

const randomizeFilter = (): Filters => {
  const filters: Filters = {};

  // Apply a random filter to 80% of the users
  if (Math.random() > 0.2) {
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

export const healthCheck: FunctionHook<StakePoolSearchVars> = async (ctx, ee, done) => {
  const { vars } = ctx;

  try {
    const result = await provider.healthCheck();

    if (result.ok) vars.healthCheckResult = true;
    else {
      ee.emit('counter', 'healthCheck.unhealthy', 1);
      logger.warn('Not ok healthCheck result', result);
    }
  } catch (error) {
    ee.emit('counter', 'healthCheck.error', 1);
    logger.error('Error thrown while performing healthCheck', error);
  }

  done();
};

export const performQuery: FunctionHook<StakePoolSearchVars> = async (ctx, ee, done) => {
  const { vars, _uid } = ctx;
  const { healthCheckResult, pageResults } = vars;
  let { args } = vars;

  if (!healthCheckResult) return done();

  // If not already initialized: prepare the new request starting from the first page
  if (!args) {
    args = { pagination: { limit: PAGE_SIZE, startAt: 0 } };
    vars.args = args;
  }

  // If we have a pageResults, this is not the first call of the session: request next page
  if (pageResults) args.pagination!.startAt += PAGE_SIZE;
  // This is the first call of the first virtual user, we need to make a query that will fully prime the API cache
  else if (!firstUser) firstUser = _uid;
  // This is the first call of the session for all users but the first one: randomize query parameters
  else args.filters = randomizeFilter();

  const statsName = getStatName(ctx);

  try {
    const startedAt = Date.now();
    const result = await provider.queryStakePools(args);

    // Take ids to randomize next requests
    for (const pool of result.pageResults) if (!poolIds.includes(pool.id)) poolIds.push(pool.id);

    // Store the result in the context
    vars.pageResults = result.pageResults;
    vars.totalResultCount = result.totalResultCount;

    // Emit custom metrics
    ee.emit('histogram', `${statsName}.time`, Date.now() - startedAt);
    ee.emit('counter', statsName, 1);
  } catch (error) {
    ee.emit('counter', `${statsName}.error`, 1);
    vars.gotError = true;
    logger.error(error);
  }

  done();
};

export const moreResults: WhileTrueHook<StakePoolSearchVars> = (ctx, done) => {
  const { args, healthCheckResult, gotError, pageResults, totalResultCount } = ctx.vars;

  done(!gotError && healthCheckResult && totalResultCount > args.pagination!.startAt + pageResults.length);
};
