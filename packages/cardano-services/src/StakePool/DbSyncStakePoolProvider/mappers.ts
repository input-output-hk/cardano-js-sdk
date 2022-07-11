import { Cardano, StakePoolSearchResults, StakePoolStats } from '@cardano-sdk/core';
import {
  EpochReward,
  EpochRewardModel,
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
  RelayModel,
  StakePoolStatsModel
} from './types';
import { isNotNil } from '@cardano-sdk/util';
import Fraction from 'fraction.js';

const toHexString = (bytes: Buffer) => bytes.toString('hex');

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

interface ToCoreStakePoolInput {
  poolOwners: PoolOwner[];
  poolDatas: PoolData[];
  poolRegistrations: PoolRegistration[];
  poolRelays: PoolRelay[];
  poolRetirements: PoolRetirement[];
  poolRewards: EpochReward[];
  lastEpoch: number;
  poolMetrics: PoolMetrics[];
  totalCount: number;
  poolAPYs: PoolAPY[];
}

export const toCoreStakePool = (
  poolHashIds: number[],
  {
    poolOwners,
    poolDatas,
    poolRegistrations,
    poolRelays,
    poolRetirements,
    poolRewards,
    lastEpoch,
    poolMetrics,
    totalCount,
    poolAPYs
  }: ToCoreStakePoolInput
): StakePoolSearchResults => ({
  pageResults: poolHashIds
    .map((hashId) => {
      const poolData = poolDatas.find((data) => data.hashId === hashId);
      if (!poolData) return;
      const apy = poolAPYs.find((pool) => pool.hashId === hashId)?.apy;
      const registrations = poolRegistrations.filter((r) => r.hashId === poolData.hashId);
      const retirements = poolRetirements.filter((r) => r.hashId === poolData.hashId);
      const metrics = poolMetrics.find((metric) => metric.hashId === poolData.hashId)?.metrics;
      const toReturn: Cardano.StakePool = {
        cost: poolData.cost,
        epochRewards: poolRewards.filter((r) => r.hashId === poolData.hashId).map((reward) => reward.epochReward),
        hexId: poolData.hexId,
        id: poolData.id,
        margin: poolData.margin,
        metrics: metrics ? { ...metrics, apy } : ({} as Cardano.StakePoolMetrics),
        owners: poolOwners.filter((o) => o.hashId === poolData.hashId).map((o) => o.address),
        pledge: poolData.pledge,
        relays: poolRelays.filter((r) => r.updateId === poolData.updateId).map((r) => r.relay),
        rewardAccount: poolData.rewardAccount,
        status: getPoolStatus(registrations[0], lastEpoch, retirements[0]),
        transactions: {
          registration: registrations.map((r) => r.transactionId),
          retirement: retirements.map((r) => r.transactionId)
        },
        vrf: poolData.vrfKeyHash
      };
      if (poolData.metadata) toReturn.metadata = poolData.metadata;
      if (poolData.metadataJson) toReturn.metadataJson = poolData.metadataJson;
      return toReturn;
    })
    .filter(isNotNil),
  totalResultCount: Number(totalCount)
});

export const mapPoolUpdate = (poolUpdateModel: PoolUpdateModel): PoolUpdate => ({
  id: poolUpdateModel.id,
  updateId: poolUpdateModel.update_id
});

const metadataKeys = new Set(['ticker', 'name', 'description', 'homepage']);

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const isOfflineMetadata = (_object: any): _object is Cardano.StakePoolMetadataFields =>
  Object.keys(_object).every((k) => metadataKeys.has(k) && typeof _object[k] === 'string');

export const mapPoolData = (poolDataModel: PoolDataModel): PoolData => {
  const vrfAsHexString = toHexString(poolDataModel.vrf_key_hash);
  const { n: numerator, d: denominator } = new Fraction(poolDataModel.margin);
  const toReturn: PoolData = {
    cost: BigInt(poolDataModel.fixed_cost),
    hashId: poolDataModel.hash_id,
    hexId: Cardano.PoolIdHex(toHexString(poolDataModel.pool_hash)),
    id: Cardano.PoolId(poolDataModel.pool_id),
    margin: { denominator, numerator },
    pledge: BigInt(poolDataModel.pledge),
    rewardAccount: Cardano.RewardAccount(poolDataModel.reward_address),
    updateId: poolDataModel.update_id,
    vrfKeyHash: Cardano.VrfVkHex(vrfAsHexString)
  };
  if (poolDataModel.metadata_hash) {
    toReturn.metadataJson = {
      hash: Cardano.util.Hash32ByteBase16(toHexString(poolDataModel.metadata_hash)),
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

  return { hashId: relayModel.hash_id, relay, updateId: relayModel.update_id };
};

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
  hashId: ownerAddressModel.hash_id
});

export const mapPoolRegistration = (poolRegistrationModel: PoolRegistrationModel): PoolRegistration => ({
  activeEpochNo: poolRegistrationModel.active_epoch_no,
  hashId: poolRegistrationModel.hash_id,
  transactionId: Cardano.TransactionId(toHexString(poolRegistrationModel.tx_hash))
});

export const mapPoolRetirement = (poolRetirementModel: PoolRetirementModel): PoolRetirement => ({
  hashId: poolRetirementModel.hash_id,
  retiringEpoch: poolRetirementModel.retiring_epoch,
  transactionId: Cardano.TransactionId(toHexString(poolRetirementModel.tx_hash))
});

export const mapPoolMetrics = (poolMetricsModel: PoolMetricsModel): PoolMetrics => ({
  hashId: poolMetricsModel.pool_hash_id,
  metrics: {
    blocksCreated: poolMetricsModel.blocks_created,
    delegators: poolMetricsModel.delegators,
    livePledge: BigInt(poolMetricsModel.live_pledge),
    saturation: poolMetricsModel.saturation,
    size: {
      active: poolMetricsModel.active_stake_percentage,
      live: poolMetricsModel.live_stake_percentage
    },
    stake: {
      active: BigInt(poolMetricsModel.active_stake),
      live: BigInt(poolMetricsModel.live_stake)
    }
  }
});

export const mapPoolStats = (poolStats: StakePoolStatsModel): StakePoolStats => ({
  qty: { active: Number(poolStats.active), retired: Number(poolStats.retired), retiring: Number(poolStats.retiring) }
});

export const mapPoolAPY = (poolAPYModel: PoolAPYModel): PoolAPY => ({
  apy: poolAPYModel.apy,
  hashId: poolAPYModel.hash_id
});
