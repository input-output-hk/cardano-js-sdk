import { Cardano, StakeDistribution, StakePoolStats } from '@cardano-sdk/core';
import {
  Epoch,
  EpochModel,
  EpochReward,
  EpochRewardModel,
  HashIdStakePoolMap,
  OwnerAddressModel,
  PoolAPY,
  PoolAPYModel,
  PoolData,
  PoolDataModel,
  PoolMetrics,
  PoolMetricsModel,
  PoolOwner,
  PoolRegistration,
  PoolRegistrationModel,
  PoolRelay,
  PoolRetirement,
  PoolRetirementModel,
  PoolUpdate,
  PoolUpdateModel,
  PoolsToCache,
  RelayModel,
  StakePoolResults,
  StakePoolStatsModel
} from './types';
import { bufferToHexString, isNotNil } from '@cardano-sdk/util';
import { divideBigIntToFloat } from './util';
import Fraction from 'fraction.js';

const getPoolStatus = (
  lastPoolRegistration: PoolRegistration,
  lastEpoch: number,
  lastPoolRetirement?: PoolRetirement
) => {
  if (lastPoolRetirement === undefined || lastPoolRetirement.retiringEpoch <= lastPoolRegistration.activeEpochNo) {
    if (lastPoolRegistration.activeEpochNo > lastEpoch) return Cardano.StakePoolStatus.Activating;
    return Cardano.StakePoolStatus.Active;
  }
  if (lastPoolRetirement.retiringEpoch > lastEpoch) return Cardano.StakePoolStatus.Retiring;
  return Cardano.StakePoolStatus.Retired;
};

interface NodeMetricsDependencies {
  stakeDistribution: StakeDistribution;
  totalAdaAmount: Cardano.Lovelace;
  optimalPoolCount?: number;
}

interface ToCoreStakePoolInput {
  poolOwners: PoolOwner[];
  poolDatas: PoolData[];
  poolRegistrations: PoolRegistration[];
  poolRelays: PoolRelay[];
  poolRetirements: PoolRetirement[];
  poolRewards: EpochReward[];
  lastEpochNo: Cardano.EpochNo;
  poolMetrics: PoolMetrics[];
  totalCount: number;
  poolAPYs: PoolAPY[];
  nodeMetricsDependencies: NodeMetricsDependencies;
}

/**
 * Calculates metrics that depends on Node's retrieved data.
 * Since some metrics are obtained from the Node they have to be calculated outside db queries
 */
export const calcNodeMetricsValues = (
  poolId: Cardano.PoolId,
  metrics: PoolMetrics['metrics'],
  { totalAdaAmount, stakeDistribution, optimalPoolCount = 0 }: NodeMetricsDependencies,
  apy: number
): Cardano.StakePoolMetrics => {
  const { activeStake, ...rest } = metrics;
  const stakePoolMetrics = { ...rest, apy } as unknown as Cardano.StakePoolMetrics;
  const poolStake = stakeDistribution.get(poolId)?.stake;
  const liveStake = poolStake ? poolStake.pool : 0n;
  const totalStake = liveStake + activeStake;
  const isZeroStake = totalStake === 0n;
  const activePercentage = !isZeroStake ? Number(divideBigIntToFloat(activeStake, totalStake)) : 0;
  const size: Cardano.StakePoolMetricsSize = {
    active: activePercentage,
    live: !isZeroStake ? 1 - activePercentage : 0
  };
  const stake: Cardano.StakePoolMetricsStake = {
    active: activeStake,
    live: liveStake
  };
  stakePoolMetrics.size = size;
  stakePoolMetrics.stake = stake;
  stakePoolMetrics.saturation = Number(divideBigIntToFloat(totalStake * BigInt(optimalPoolCount), totalAdaAmount));
  return stakePoolMetrics;
};

export const toStakePoolResults = (
  poolHashIds: number[],
  fromCache: HashIdStakePoolMap,
  {
    poolOwners,
    poolDatas,
    poolRegistrations,
    poolRelays,
    poolRetirements,
    poolRewards,
    lastEpochNo,
    poolMetrics,
    totalCount,
    poolAPYs,
    nodeMetricsDependencies
  }: ToCoreStakePoolInput
): StakePoolResults => {
  const poolsToCache: PoolsToCache = {};
  return {
    poolsToCache,
    results: {
      pageResults: poolHashIds
        .map((hashId) => {
          const poolData = poolDatas.find((data) => data.hashId === hashId);
          if (!poolData) return;

          const epochRewards = poolRewards
            .filter((r) => r.hashId === poolData.hashId)
            .map((reward) => reward.epochReward);

          // Get the cached value if given hash id persist in the in-memory cache
          if (fromCache[hashId]) return { ...fromCache[hashId], epochRewards } as Cardano.StakePool;

          const apy = poolAPYs.find((pool) => pool.hashId === hashId)?.apy;
          const registrations = poolRegistrations.filter((r) => r.hashId === poolData.hashId);
          const retirements = poolRetirements.filter((r) => r.hashId === poolData.hashId);
          const partialMetrics = poolMetrics.find((metric) => metric.hashId === poolData.hashId)?.metrics;
          let metrics: Cardano.StakePoolMetrics | undefined;
          if (partialMetrics) {
            metrics = calcNodeMetricsValues(poolData.id, partialMetrics, nodeMetricsDependencies, apy!);
          }
          const coreStakePool: Cardano.StakePool = {
            cost: poolData.cost,
            epochRewards,
            hexId: poolData.hexId,
            id: poolData.id,
            margin: poolData.margin,
            metrics: metrics ? metrics : ({} as Cardano.StakePoolMetrics),
            owners: poolOwners.filter((o) => o.hashId === poolData.hashId).map((o) => o.address),
            pledge: poolData.pledge,
            relays: poolRelays.filter((r) => r.updateId === poolData.updateId).map((r) => r.relay),
            rewardAccount: poolData.rewardAccount,
            status: getPoolStatus(registrations[0], lastEpochNo, retirements[0]),
            transactions: {
              registration: registrations.map((r) => r.transactionId),
              retirement: retirements.map((r) => r.transactionId)
            },
            vrf: poolData.vrfKeyHash
          };
          if (poolData.metadata) coreStakePool.metadata = poolData.metadata;
          if (poolData.metadataJson) coreStakePool.metadataJson = poolData.metadataJson;

          // Mark stake pool as pool to cache
          poolsToCache[hashId] = coreStakePool;

          return coreStakePool;
        })
        .filter(isNotNil),
      totalResultCount: Number(totalCount)
    }
  };
};

export const mapPoolUpdate = (poolUpdateModel: PoolUpdateModel): PoolUpdate => ({
  id: Number(poolUpdateModel.id),
  updateId: Number(poolUpdateModel.update_id)
});

const metadataKeys = new Set(['ticker', 'name', 'description', 'homepage']);

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const isOfflineMetadata = (_object: any): _object is Cardano.StakePoolMetadataFields =>
  Object.keys(_object).every((k) => metadataKeys.has(k) && typeof _object[k] === 'string');

export const mapPoolData = (poolDataModel: PoolDataModel): PoolData => {
  const vrfAsHexString = bufferToHexString(poolDataModel.vrf_key_hash);
  const { n: numerator, d: denominator } = new Fraction(poolDataModel.margin);
  const toReturn: PoolData = {
    cost: BigInt(poolDataModel.fixed_cost),
    hashId: Number(poolDataModel.hash_id),
    hexId: Cardano.PoolIdHex(bufferToHexString(poolDataModel.pool_hash)),
    id: Cardano.PoolId(poolDataModel.pool_id),
    margin: { denominator, numerator },
    pledge: BigInt(poolDataModel.pledge),
    rewardAccount: Cardano.RewardAccount(poolDataModel.reward_address),
    updateId: Number(poolDataModel.update_id),
    vrfKeyHash: Cardano.VrfVkHex(vrfAsHexString)
  };
  if (poolDataModel.metadata_hash) {
    toReturn.metadataJson = {
      hash: Cardano.util.Hash32ByteBase16(bufferToHexString(poolDataModel.metadata_hash)),
      url: poolDataModel.metadata_url
    };
  }
  if (poolDataModel.offline_data) {
    const parsedData = poolDataModel.offline_data;
    if (isOfflineMetadata(parsedData)) toReturn.metadata = parsedData;
  }
  return toReturn;
};

export const mapRelay = (relayModel: RelayModel): PoolRelay => {
  let relay: Cardano.Relay;
  if (relayModel.hostname) {
    relay = { __typename: 'RelayByName', hostname: relayModel.hostname, port: relayModel.port };
  } else if (relayModel.dns_name) {
    relay = {
      __typename: 'RelayByNameMultihost',
      dnsName: relayModel.dns_name
    };
  } else
    relay = {
      __typename: 'RelayByAddress',
      ipv4: relayModel.ipv4,
      ipv6: relayModel.ipv6,
      port: relayModel.port
    };

  return { hashId: Number(relayModel.hash_id), relay, updateId: Number(relayModel.update_id) };
};

export const mapEpoch = ({ no, optimal_pool_count }: EpochModel): Epoch => ({
  no,
  optimalPoolCount: optimal_pool_count
});

export const mapEpochReward = (epochRewardModel: EpochRewardModel, hashId: number): EpochReward => ({
  epochReward: {
    activeStake: BigInt(epochRewardModel.active_stake),
    epoch: epochRewardModel.epoch_no,
    epochLength: Number(epochRewardModel.epoch_length),
    memberROI: epochRewardModel.member_roi,
    operatorFees: BigInt(epochRewardModel.operator_fees),
    totalRewards: BigInt(epochRewardModel.total_rewards)
  },
  hashId
});

export const mapAddressOwner = (ownerAddressModel: OwnerAddressModel): PoolOwner => ({
  address: Cardano.RewardAccount(ownerAddressModel.address),
  hashId: Number(ownerAddressModel.hash_id)
});

export const mapPoolRegistration = (poolRegistrationModel: PoolRegistrationModel): PoolRegistration => ({
  activeEpochNo: poolRegistrationModel.active_epoch_no,
  hashId: Number(poolRegistrationModel.hash_id),
  transactionId: Cardano.TransactionId(bufferToHexString(poolRegistrationModel.tx_hash))
});

export const mapPoolRetirement = (poolRetirementModel: PoolRetirementModel): PoolRetirement => ({
  hashId: Number(poolRetirementModel.hash_id),
  retiringEpoch: poolRetirementModel.retiring_epoch,
  transactionId: Cardano.TransactionId(bufferToHexString(poolRetirementModel.tx_hash))
});

export const mapPoolMetrics = (poolMetricsModel: PoolMetricsModel): PoolMetrics => ({
  hashId: Number(poolMetricsModel.pool_hash_id),
  metrics: {
    activeStake: BigInt(poolMetricsModel.active_stake),
    blocksCreated: poolMetricsModel.blocks_created,
    delegators: poolMetricsModel.delegators,
    livePledge: BigInt(poolMetricsModel.live_pledge),
    saturation: Number.parseFloat(poolMetricsModel.saturation)
  }
});

export const mapPoolStats = (poolStats: StakePoolStatsModel): StakePoolStats => ({
  qty: { active: Number(poolStats.active), retired: Number(poolStats.retired), retiring: Number(poolStats.retiring) }
});

export const mapPoolAPY = (poolAPYModel: PoolAPYModel): PoolAPY => ({
  apy: poolAPYModel.apy,
  hashId: Number(poolAPYModel.hash_id)
});
