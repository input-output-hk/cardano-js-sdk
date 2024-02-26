import { Between, DataSource, LessThanOrEqual } from 'typeorm';
import { Cardano, NetworkInfoProvider, epochSlotsCalcFactory } from '@cardano-sdk/core';
import {
  CurrentPoolMetricsEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  PoolRewardsEntity,
  STAKE_POOL_REWARDS,
  StakePoolEntity,
  StakePoolRewardsJob
} from '@cardano-sdk/projection-typeorm';
import { MissingProgramOption } from '../Program/errors';
import { RewardsComputeContext, WorkerHandlerFactory } from './types';
import { ServiceNames } from '../Program/programs/types';
import { accountActiveStake, poolDelegators, poolRewards } from './stakePoolRewardsQueries';
import { computeROS } from '../StakePool/TypeormStakePoolProvider/util';
import { missingProviderUrlOption } from '../Program/options/common';
import { networkInfoHttpProvider } from '@cardano-sdk/cardano-services-client';

/** The version of the algorithm to compute rewards. */
export const REWARDS_COMPUTE_VERSION = 1;

/** Gets from **db-sync** the _active stake_. */
const getPoolActiveStake = async (context: RewardsComputeContext) => {
  const { db, delegatorsIds, epochNo, ownersIds } = context;

  context.memberActiveStake = 0n;
  context.activeStake = 0n;

  for (const delegatorId of delegatorsIds!) {
    const { rows, rowCount } = await db.query<{ value: string }>({
      name: 'get_active_stake',
      text: accountActiveStake,
      values: [epochNo, delegatorId]
    });

    if (rowCount > 0) {
      const amount = BigInt(rows[0].value);

      context.activeStake += amount;
      if (!ownersIds!.includes(delegatorId)) context.memberActiveStake += amount;
    }
  }
};

/** Gets from **db-sync** the _delegators_ (`stake_address.id` arrays). */
const getPoolDelegators = async (context: RewardsComputeContext) => {
  context.delegatorsIds = [];
  context.membersIds = [];
  context.ownersIds = [];

  const { db, delegatorsIds, epochNo, membersIds, ownersIds, poolHashId, registration } = context;
  const { owners } = registration!;
  const { rows } = await db.query<{ addr_id: string; owner: boolean }>({
    name: 'get_delegators',
    text: poolDelegators,
    values: [epochNo, poolHashId, owners]
  });

  context.delegators = rows.length;

  for (const { addr_id, owner } of rows) {
    delegatorsIds.push(addr_id);

    if (owner) ownersIds.push(addr_id);
    else membersIds.push(addr_id);
  }
};

/** Gets from **db-sync** the `pool_hash.id`. */
const getPoolHashId = async (context: RewardsComputeContext) => {
  const { db, stakePool } = context;
  const result = await db.query<{ id: string }>({
    name: 'get_hash_id',
    text: 'SELECT id FROM pool_hash WHERE view = $1',
    values: [stakePool.id]
  });

  if (result.rowCount !== 1) throw new Error('Expected exactly 1 row');

  context.poolHashId = result.rows[0].id;
};

/** Gets from **db-sync** the _rewards_. */
const getPoolRewards = async (context: RewardsComputeContext) => {
  const { db, epochNo, poolHashId } = context;
  const result = await db.query<{ amount: string; type: string }>({
    name: 'get_rewards',
    text: poolRewards,
    values: [epochNo, poolHashId]
  });

  context.leaderRewards = 0n;
  context.memberRewards = 0n;
  context.rewards = 0n;

  for (const { amount, type } of result.rows) {
    const biAmount = BigInt(amount);

    if (type === 'leader') context.leaderRewards += biAmount;
    if (type === 'member') context.memberRewards += biAmount;
    context.rewards += biAmount;
  }
};

/**
 * Checks if the job for previous epoch already completed accessing the **pg-boss** `job` table.
 *
 * In case previous job is not yet completed, `throw`s an `Error`.
 */
const checkPreviousEpochCompleted = async (dataSource: DataSource, epochNo: Cardano.EpochNo) => {
  // Epoch no 0 doesn't need to wait for any jobs about previous epoch
  if (epochNo === 0) return;

  const queryRunner = dataSource.createQueryRunner();

  try {
    const subQuery = (table: 'archive' | 'job') =>
      `(SELECT COUNT(*) FROM pgboss.${table} WHERE name = $1 AND singletonkey = $2 AND state = $3)`;
    const result: { completed: string }[] = await queryRunner.query(
      `SELECT ${subQuery('archive')} + ${subQuery('job')} AS completed`,
      [STAKE_POOL_REWARDS, epochNo - 1, 'completed']
    );

    if (result[0]?.completed !== '1') throw new Error('Previous epoch rewards job not completed yet');
  } finally {
    await queryRunner.release();
  }
};

/**
 * Checks if a given pool needs to compute the rewards in a given epoch based on its status in that epoch.
 *
 * It also adds the `registration` to the `context`.
 *
 * @param context the computation context
 * @returns `true` if the pool has rewards to compute, `false` otherwise
 */
const hasRewardsInEpoch = async (context: RewardsComputeContext) => {
  const { dataSource, epochNo, lastSlot, stakePool } = context;
  const { id } = stakePool;
  const registration = await dataSource.getRepository(PoolRegistrationEntity).findOne({
    order: { blockSlot: 'DESC' },
    where: { blockSlot: LessThanOrEqual(lastSlot), stakePool: { id } }
  });

  if (!registration) return false;

  const retirements = await dataSource.getRepository(PoolRetirementEntity).count({
    where: {
      blockSlot: Between(registration.blockSlot!, lastSlot),
      retireAtEpoch: LessThanOrEqual(epochNo),
      stakePool: { id }
    }
  });

  if (retirements !== 0) return false;

  context.registration = registration;

  return true;
};

/**
 * Computes the rewards for a given stake pool in a given epoch; stores it into the DB
 * and updates ROS and lastROS for the stake pool in its metrics.
 *
 * @param context the computation context
 */
const epochRewards = async (context: RewardsComputeContext) => {
  const { dataSource, epochNo, idx, lastRosEpochs, logger, stakePool, totalStakePools } = context;
  const { id } = stakePool;

  if (await hasRewardsInEpoch(context)) {
    logger.info(`Going to compute rewards for stake pool ${id} on epoch ${epochNo} (${idx}/${totalStakePools})`);

    await getPoolHashId(context);
    await getPoolDelegators(context);
    await getPoolRewards(context);
    await getPoolActiveStake(context);

    const { registration } = context;

    context.pledge = registration!.pledge!;
    context.version = REWARDS_COMPUTE_VERSION;

    logger.debug(`Going to upsert epoch rewards for stake pool ${id}`);

    await dataSource.getRepository(PoolRewardsEntity).upsert(context, ['epochNo', 'stakePoolId']);

    logger.debug(`Epoch rewards for stake pool ${id} saved`);
  }

  const [ros] = await computeROS(context);
  const [lastRos] = await computeROS({ ...context, epochs: lastRosEpochs });

  logger.debug(`Going to refresh ROS metrics for stake pool ${id}`);

  await dataSource.getRepository(CurrentPoolMetricsEntity).upsert({ lastRos, ros, stakePool: { id } }, ['stakePoolId']);

  logger.debug(`ROS metrics for stake pool ${id} saved`);
};

/** Gets the last slot of the epoch. */
const getLastSlot = async (provider: NetworkInfoProvider, epochNo: Cardano.EpochNo) => {
  const epochSlotsCalc = epochSlotsCalcFactory(provider);
  const { firstSlot, lastSlot } = await epochSlotsCalc(epochNo);

  return { epochLength: (lastSlot - firstSlot + 1) * 1000, lastSlot };
};

/** Creates a `stakePoolRewardsHandler`. */
export const stakePoolRewardsHandlerFactory: WorkerHandlerFactory = (options) => {
  const { dataSource, db, lastRosEpochs, logger, networkInfoProviderUrl } = options;

  // Introduced following code repetition as the correct form is source of a circular-deps:check failure.
  // Solving it would require an invasive refactoring action, probably better to defer it.
  // if (!lastRosEpochs) throw new MissingProgramOption(STAKE_POOL_REWARDS, Descriptions.LastRosEpochs);
  if (!lastRosEpochs)
    throw new MissingProgramOption(STAKE_POOL_REWARDS, 'Number of epochs over which lastRos is computed');
  if (!networkInfoProviderUrl) throw missingProviderUrlOption(STAKE_POOL_REWARDS, ServiceNames.NetworkInfo);

  const provider = networkInfoHttpProvider({ baseUrl: networkInfoProviderUrl, logger });

  return async (data: StakePoolRewardsJob) => {
    const { epochNo } = data;

    logger.info(`Starting stake pools rewards job for epoch ${epochNo}`);

    await checkPreviousEpochCompleted(dataSource, epochNo);

    const { epochLength, lastSlot } = await getLastSlot(provider, epochNo);
    const stakePools = await dataSource.getRepository(StakePoolEntity).find();
    const totalStakePools = stakePools.length;
    const context = { dataSource, db, epochLength, epochNo, lastRosEpochs, lastSlot, logger, totalStakePools };

    for (const [idx, stakePool] of stakePools.entries()) await epochRewards({ ...context, idx, stakePool });
  };
};
