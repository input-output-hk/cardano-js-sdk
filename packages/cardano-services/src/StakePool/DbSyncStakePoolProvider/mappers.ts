/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano } from '@cardano-sdk/core';
import { Percent, bufferToHexString, isNotNil } from '@cardano-sdk/util';
import Fraction from 'fraction.js';
import type {
  BlockfrostPoolMetrics,
  BlockfrostPoolMetricsModel,
  Epoch,
  EpochModel,
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
} from './types.js';
import type { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import type { StakePoolStats } from '@cardano-sdk/core';

const getPoolStatus = (
  lastPoolRegistration: PoolRegistration,
  lastEpoch: number,
  lastPoolRetirement?: PoolRetirement
): Cardano.StakePoolStatus => {
  if (lastPoolRetirement === undefined || lastPoolRetirement.retiringEpoch <= lastPoolRegistration.activeEpochNo) {
    if (lastPoolRegistration.activeEpochNo > lastEpoch) return Cardano.StakePoolStatus.Activating;
    return Cardano.StakePoolStatus.Active;
  }
  if (lastPoolRetirement.retiringEpoch > lastEpoch) return Cardano.StakePoolStatus.Retiring;
  return Cardano.StakePoolStatus.Retired;
};

interface ToCoreStakePoolInput {
  poolOwners: PoolOwner[];
  poolDatas: PoolData[];
  poolRegistrations: PoolRegistration[];
  poolRelays: PoolRelay[];
  poolRetirements: PoolRetirement[];
  lastEpochNo: Cardano.EpochNo;
  poolMetrics: PoolMetrics[];
  totalCount: number;
  poolAPYs: PoolAPY[];
}

/**
 * Calculates metrics that depends on Node's retrieved data.
 * Since some metrics are obtained from the Node they have to be calculated outside db queries
 */
export const calcNodeMetricsValues = (metrics: PoolMetrics['metrics'], apy?: number): Cardano.StakePoolMetrics => {
  const { activeStake, liveStake, activeStakePercentage, ...rest } = metrics;
  const stakePoolMetrics = { ...rest, apy } as unknown as Cardano.StakePoolMetrics;
  const isZeroStake = liveStake === 0n;
  const size: Cardano.StakePoolMetricsSize = {
    active: activeStakePercentage,
    live: Percent(!isZeroStake ? 1 - activeStakePercentage : 0)
  };
  const stake: Cardano.StakePoolMetricsStake = {
    active: activeStake,
    live: liveStake
  };
  stakePoolMetrics.size = size;
  stakePoolMetrics.stake = stake;
  return stakePoolMetrics;
};

export const toStakePoolResults = (
  poolHashIds: number[],
  fromCache: HashIdStakePoolMap,
  useBlockfrost: boolean,
  {
    poolOwners,
    poolDatas,
    poolRegistrations,
    poolRelays,
    poolRetirements,
    lastEpochNo,
    poolMetrics,
    totalCount,
    poolAPYs
  }: ToCoreStakePoolInput
): StakePoolResults => {
  const poolsToCache: PoolsToCache = {};
  return {
    poolsToCache,
    results: {
      pageResults: poolHashIds
        // eslint-disable-next-line complexity
        .map((hashId) => {
          const poolData = poolDatas.find((data) => data.hashId === hashId);
          if (!poolData) return;

          // Get the cached value if given hash id persist in the in-memory cache
          if (fromCache[hashId]) return fromCache[hashId];

          const apy = poolAPYs.find((pool) => pool.hashId === hashId)?.apy;
          const registration = poolRegistrations.find((r) => r.hashId === poolData.hashId);
          const retirement = poolRetirements.find((r) => r.hashId === poolData.hashId);
          const poolMetric = (poolMetrics as BlockfrostPoolMetrics[]).find(
            (metric) => metric.hashId === poolData.hashId
          );
          const partialMetrics = poolMetric?.metrics;
          let metrics: Cardano.StakePoolMetrics | undefined;
          if (partialMetrics) {
            metrics = calcNodeMetricsValues(partialMetrics, apy);
          }
          const coreStakePool: Cardano.StakePool = {
            cost: poolData.cost,
            hexId: poolData.hexId,
            id: poolData.id,
            margin: poolData.margin,
            metrics: metrics ? metrics : ({} as Cardano.StakePoolMetrics),
            pledge: poolData.pledge,
            relays: poolRelays.filter((r) => r.updateId === poolData.updateId).map((r) => r.relay),
            vrf: poolData.vrfKeyHash,
            ...(useBlockfrost
              ? {
                  owners: poolMetric?.owners || [],
                  rewardAccount: poolMetric?.rewardAccount || ('' as Cardano.RewardAccount),
                  status: poolMetric?.status || Cardano.StakePoolStatus.Retired
                }
              : {
                  owners: poolOwners.filter((o) => o.hashId === poolData.hashId).map((o) => o.address),
                  rewardAccount: poolData.rewardAccount,
                  status: getPoolStatus(registration!, lastEpochNo, retirement)
                })
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

const metadataKeys = new Set([
  'ticker',
  'name',
  'description',
  'homepage',
  'extended',
  'extDataUrl',
  'extSigUrl',
  'extVkey'
]);

const isOfflineMetadata = (
  _object: any
): _object is Cardano.StakePoolMainMetadataFields & Cardano.Cip6MetadataFields & Cardano.APMetadataFields =>
  Object.keys(_object).every((k) => metadataKeys.has(k) && typeof _object[k] === 'string');

export const mapPoolData = (poolDataModel: PoolDataModel): PoolData => {
  const vrfAsHexString = bufferToHexString(poolDataModel.vrf_key_hash);
  const { n: numerator, d: denominator } = new Fraction(poolDataModel.margin);
  const toReturn: PoolData = {
    cost: BigInt(poolDataModel.fixed_cost),
    hashId: Number(poolDataModel.hash_id),
    hexId: bufferToHexString(poolDataModel.pool_hash) as unknown as Cardano.PoolIdHex,
    id: poolDataModel.pool_id as unknown as Cardano.PoolId,
    margin: { denominator, numerator },
    pledge: BigInt(poolDataModel.pledge),
    rewardAccount: poolDataModel.reward_address as unknown as Cardano.RewardAccount,
    updateId: Number(poolDataModel.update_id),
    vrfKeyHash: vrfAsHexString as unknown as Cardano.VrfVkHex
  };
  if (poolDataModel.metadata_hash) {
    toReturn.metadataJson = {
      hash: bufferToHexString(poolDataModel.metadata_hash) as unknown as Hash32ByteBase16,
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

export const mapAddressOwner = (ownerAddressModel: OwnerAddressModel): PoolOwner => ({
  address: ownerAddressModel.address as unknown as Cardano.RewardAccount,
  hashId: Number(ownerAddressModel.hash_id)
});

export const mapPoolRegistration = (poolRegistrationModel: PoolRegistrationModel): PoolRegistration => ({
  activeEpochNo: poolRegistrationModel.active_epoch_no,
  hashId: Number(poolRegistrationModel.hash_id),
  transactionId: bufferToHexString(poolRegistrationModel.tx_hash) as unknown as Cardano.TransactionId
});

export const mapPoolRetirement = (poolRetirementModel: PoolRetirementModel): PoolRetirement => ({
  hashId: Number(poolRetirementModel.hash_id),
  retiringEpoch: poolRetirementModel.retiring_epoch,
  transactionId: bufferToHexString(poolRetirementModel.tx_hash) as unknown as Cardano.TransactionId
});

export const mapPoolMetrics = (poolMetricsModel: PoolMetricsModel): PoolMetrics => ({
  hashId: Number(poolMetricsModel.pool_hash_id),
  metrics: {
    activeStake: BigInt(poolMetricsModel.active_stake),
    activeStakePercentage: Percent(Number(poolMetricsModel.active_stake_percentage)),
    blocksCreated: poolMetricsModel.blocks_created,
    delegators: poolMetricsModel.delegators,
    lastRos: Percent(0),
    livePledge: BigInt(poolMetricsModel.live_pledge),
    liveStake: BigInt(poolMetricsModel.live_stake),
    ros: Percent(0),
    saturation: Percent(Number.parseFloat(poolMetricsModel.saturation))
  }
});

export const mapBlockfrostPoolMetrics = (poolMetricsModel: BlockfrostPoolMetricsModel): BlockfrostPoolMetrics => {
  const { extra, reward_address, status } = poolMetricsModel;
  const [owners, registration, retirement] = JSON.parse(extra);

  return {
    ...mapPoolMetrics(poolMetricsModel),
    owners,
    registration,
    retirement,
    rewardAccount: reward_address as unknown as Cardano.RewardAccount,
    status: status as unknown as Cardano.StakePoolStatus
  };
};

export const mapPoolStats = (poolStats: StakePoolStatsModel): StakePoolStats => ({
  qty: {
    // There is no need of resolving this for db-sync provider, will be deprecated soon with the optimized postgres one
    activating: 0,
    active: Number(poolStats.active),
    retired: Number(poolStats.retired),
    retiring: Number(poolStats.retiring)
  }
});

export const mapPoolAPY = (poolAPYModel: PoolAPYModel): PoolAPY => ({
  apy: poolAPYModel.apy,
  hashId: Number(poolAPYModel.hash_id)
});
