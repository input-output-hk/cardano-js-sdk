import { AsyncAction, InMemoryCache, UNLIMITED_CACHE_TTL } from '../../InMemoryCache';
import { NetworkInfoCacheKey } from '.';
import { Shutdown } from '@cardano-sdk/util';

export const EPOCH_POLL_INTERVAL_DEFAULT = 10_000;

export const epochPollService = (
  cache: InMemoryCache,
  asyncAction: AsyncAction<number>,
  interval: number
): Shutdown => {
  const executePoll = async () => {
    const lastEpoch = await asyncAction();
    const currentEpoch = cache.getVal<number>(NetworkInfoCacheKey.CURRENT_EPOCH);
    const shouldInvalidateEpochValues = !!(currentEpoch && lastEpoch > currentEpoch);

    if (!currentEpoch || shouldInvalidateEpochValues) {
      cache.set<number>(NetworkInfoCacheKey.CURRENT_EPOCH, lastEpoch, UNLIMITED_CACHE_TTL);
      shouldInvalidateEpochValues
        ? cache.invalidate([
            NetworkInfoCacheKey.TOTAL_SUPPLY,
            NetworkInfoCacheKey.ACTIVE_STAKE,
            NetworkInfoCacheKey.ERA_SUMMARIES
          ])
        : void 0;
    }
  };

  const timeout = setInterval(executePoll, interval);

  return {
    shutdown: () => clearInterval(timeout)
  };
};
