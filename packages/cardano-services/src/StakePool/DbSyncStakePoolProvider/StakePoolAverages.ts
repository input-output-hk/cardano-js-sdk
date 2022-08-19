import {
  Cardano,
  Provider,
  ProviderError,
  ProviderFailure,
  StakePoolAveragesResponse,
  StakePoolProvider,
  StakePoolQueryOptions
} from '@cardano-sdk/core';
import { Logger } from 'ts-log';

/**
 * The required dependencies to create a StakePoolAverages provider.
 */
export interface StakePoolAveragesDependencies {
  logger: Logger;
  stakePoolProvider: StakePoolProvider;
}

/**
 * The sub-provider which takes care of computing and caching average values for stake pools.
 */
export class StakePoolAverages implements Provider {
  /**
   * The cached result. It is a Promise to reflect the status of the compute job:
   * - if resolved: the compute job exited correctly and the Promise stores the result
   * - if rejected: the compute job exited with error and the Promise stores the error
   * - if still pending: the compute job is still working
   *
   * Therefore it can be used (and it is) to await the end of the running compute job
   */
  #cachedResult?: Promise<StakePoolAveragesResponse>;

  /**
   * This flag is used to let the compute process to know if an async close request
   * was performed in order to let it interrupt its job.
   */
  #interruptComputeProcess = false;

  /**
   * The logger object.
   */
  #logger: Logger;

  /**
   * The provider used to perform queries on StakePool
   */
  #stakePoolProvider: StakePoolProvider;

  /**
   * The internal status of the compute job
   */
  #status: 'computed' | 'error' | 'init' | 'loading' = 'init';

  constructor(dependencies: StakePoolAveragesDependencies) {
    this.#logger = dependencies.logger;
    this.#stakePoolProvider = dependencies.stakePoolProvider;
  }

  async close() {
    this.#logger.debug('Closing StakePoolAverages provider...');

    // If at least a compute job was started
    if (this.#cachedResult) {
      // Instruct the compute process (if it is running) to interrupt its job
      this.#interruptComputeProcess = true;

      // Wait for the compute process is stopped
      try {
        await this.#cachedResult;
      } catch {
        // If previous running compute job exited with error, not a problem: we need to exit
        this.#logger.warn('Running compute job exited with error');
      }
    }

    this.#logger.debug('StakePoolAverages provider closed');
  }

  /**
   * The compute job
   */
  private async compute() {
    this.#logger.debug('Starting StakePoolAverages compute job...');
    this.#status = 'loading';

    const PAGE_LENGTH = 50;

    // Init the query options at the first page
    const queryOptions: StakePoolQueryOptions = {
      filters: { status: [Cardano.StakePoolStatus.Active] },
      pagination: { limit: PAGE_LENGTH, startAt: 0 }
    };

    let lastEpochFound = -1;
    let moreResults: boolean;
    let marginPartialSum = 0n;
    let marginPartialTotal = 0;
    let rewardPartialSum = 0;
    let rewardPartialTotal = 0;

    const updatePartialResult = (pool: Cardano.StakePool) => {
      const { epochRewards, metrics } = pool;

      // No rewards for this pool, skip it
      if (epochRewards.length === 0) return;

      const lastEpochReward = epochRewards[epochRewards.length - 1];

      // Reward for this pool refers to an old epoch, skip it
      if (lastEpochReward.epoch < lastEpochFound) return;

      // Reward for this pool refers to an epoch not yet found, reset partials
      if (lastEpochReward.epoch > lastEpochFound) {
        lastEpochFound = lastEpochReward.epoch;
        marginPartialSum = 0n;
        marginPartialTotal = 0;
        rewardPartialSum = 0;
        rewardPartialTotal = 0;
      }

      marginPartialSum += lastEpochReward.totalRewards;
      marginPartialTotal++;

      if (metrics.apy !== undefined) {
        rewardPartialSum += metrics.apy;
        rewardPartialTotal++;
      }
    };

    do {
      const { pageResults, totalResultCount } = await this.#stakePoolProvider.queryStakePools(queryOptions);

      for (const pool of pageResults) updatePartialResult(pool);

      moreResults = queryOptions.pagination!.startAt + pageResults.length < totalResultCount;
      queryOptions.pagination!.startAt += PAGE_LENGTH;

      // If job is not completed but a stop request was received, stop here
      if (moreResults && this.#interruptComputeProcess)
        throw new ProviderError(ProviderFailure.ConnectionFailure, 'Interrupted due to server shut down');
    } while (moreResults);

    this.#logger.debug(`StakePoolAverages compute job ${this.#interruptComputeProcess ? 'interrupted' : 'completed'}`);

    return <StakePoolAveragesResponse>{
      epoch: lastEpochFound,
      margin: marginPartialSum / BigInt(marginPartialTotal),
      reward: rewardPartialSum / rewardPartialTotal
    };
  }

  async newEpoch() {
    // If there is a running compute job, wait until it completes before starting a new one
    if (this.#status === 'loading')
      try {
        await this.#cachedResult;
      } catch {
        // If previous running compute job exited with error, not a problem: we need to start a new one
        this.#logger.warn('Previous compute job exited with error');
      }

    this.#cachedResult = this.compute();
  }

  getAverages() {
    // If so far a compute process never started, start it as well
    if (!this.#cachedResult) this.#cachedResult = this.compute();

    return this.#cachedResult;
  }

  healthCheck() {
    return Promise.resolve({ ok: true });
  }

  async start() {
    this.#logger.debug('Starting StakePoolAverages provider...');

    this.#cachedResult = this.compute();

    this.#logger.debug('StakePoolAverages provider started');
  }
}
