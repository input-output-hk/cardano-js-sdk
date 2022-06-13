import { Cardano, StakePoolStats } from '@cardano-sdk/core';
import {
  mapAddressOwner,
  mapEpochReward,
  mapPoolAPY,
  mapPoolData,
  mapPoolMetrics,
  mapPoolRegistration,
  mapPoolRetirement,
  mapPoolStats,
  mapPoolUpdate,
  mapRelay,
  toCoreStakePool
} from '../../../src';

describe('mappers', () => {
  const txHash = '15535f16b41c6c27483b0b3346d5aaa14c3629323a642fe6518c2a27573f6354';
  const vrfKeyHash = '83a817519ec34d3c637db8f9d46fcf6f7f9e826093d1b9a8158c89da4b47a801';
  const poolHashAsHex = '5ee7591bf30eaa4f5dce70b4a676eb02d5be8012d188f04fe3beffb0';
  const metadataHash = 'cc019105f084aef2a956b2f7f2c0bf4e747bf7696705312c244620089429df6f';
  const offlineMetadata = {
    description: 'Our Amsterdam Node',
    homepage: 'https://twitter.com/A92Syed',
    name: 'THE AMSTERDAM NODE',
    ticker: 'AMS'
  };
  const update_id = 1;
  const hash_id = 1;
  const poolRetirementModel = {
    hash_id,
    retiring_epoch: 20,
    tx_hash: Buffer.from(txHash, 'hex')
  };
  const poolRegistrationModel = {
    active_epoch_no: 18,
    hash_id,
    tx_hash: Buffer.from(txHash, 'hex')
  };

  const poolRelayByName = {
    hash_id,
    hostname: 'hostname',
    port: 3001,
    update_id
  };
  const poolRelayByNameMultiHost = {
    dns_name: 'dnsName',
    hash_id,
    update_id
  };
  const poolRelayByAddress = {
    hash_id,
    ipv4: '135.181.40.207',
    port: 3001,
    update_id
  };
  const addressOwnerModel = {
    address: 'stake_test1uqrw9tjymlm8wrwq7jk68n6v7fs9qz8z0tkdkve26dylmfc2ux2hj',
    hash_id
  };
  const poolUpdateModel = {
    id: hash_id,
    update_id: 1
  };
  const poolDataModel = {
    fixed_cost: '400000000',
    hash_id,
    margin: '0.0001',
    metadata_hash: Buffer.from(metadataHash, 'hex'),
    metadata_url: 'https://git.io/JJ1dz',
    offline_data: offlineMetadata,
    pledge: '500000000',
    pool_hash: Buffer.from(poolHashAsHex, 'hex'),
    pool_id: 'pool1tmn4jxlnp64y7hwwwz62vahtqt2maqqj6xy0qnlrhmlmq3u8q0e',
    reward_address: addressOwnerModel.address,
    update_id,
    vrf_key_hash: Buffer.from(vrfKeyHash, 'hex')
  };
  const epochRewardModel = {
    active_stake: '10000000',
    epoch_length: '10000000',
    epoch_no: 2,
    member_roi: 0.000_000_05,
    operator_fees: '233333333',
    total_rewards: '99999'
  };
  const poolMetricsModel = {
    active_stake: '1000000',
    active_stake_percentage: 0.5,
    blocks_created: 20,
    delegators: 88,
    live_pledge: '99999',
    live_stake: '100000000',
    live_stake_percentage: 0.5,
    pool_hash_id: hash_id,
    saturation: 0.000_000_8
  };
  const poolAPYModel = {
    apy: 0.015,
    hash_id
  };
  it('mapPoolRetirement', () => {
    expect(mapPoolRetirement(poolRetirementModel)).toEqual({
      hashId: poolRetirementModel.hash_id,
      retiringEpoch: poolRetirementModel.retiring_epoch,
      transactionId: Cardano.TransactionId(txHash)
    });
  });
  it('mapPoolRegistration', () => {
    expect(mapPoolRegistration(poolRegistrationModel)).toEqual({
      activeEpochNo: poolRegistrationModel.active_epoch_no,
      hashId: poolRegistrationModel.hash_id,
      transactionId: Cardano.TransactionId(txHash)
    });
  });
  it('mapRelay', () => {
    expect(mapRelay(poolRelayByName)).toEqual({
      hashId: hash_id,
      relay: { __typename: 'RelayByName', hostname: poolRelayByName.hostname, port: poolRelayByName.port },
      updateId: update_id
    });
    expect(mapRelay(poolRelayByNameMultiHost)).toEqual({
      hashId: hash_id,
      relay: { __typename: 'RelayByNameMultihost', dnsName: poolRelayByNameMultiHost.dns_name },
      updateId: update_id
    });
    expect(mapRelay(poolRelayByAddress)).toEqual({
      hashId: hash_id,
      relay: { __typename: 'RelayByAddress', ipv4: poolRelayByAddress.ipv4, port: poolRelayByAddress.port },
      updateId: update_id
    });
  });
  it('mapPoolData', () => {
    expect(mapPoolData(poolDataModel)).toEqual({
      cost: BigInt(poolDataModel.fixed_cost),
      hashId: poolDataModel.hash_id,
      hexId: Cardano.PoolIdHex(poolHashAsHex),
      id: Cardano.PoolId(poolDataModel.pool_id),
      margin: { denominator: 10_000, numerator: 1 },
      metadata: poolDataModel.offline_data,
      metadataJson: {
        hash: Cardano.util.Hash32ByteBase16(metadataHash),
        url: poolDataModel.metadata_url
      },
      pledge: BigInt(poolDataModel.pledge),
      rewardAccount: Cardano.RewardAccount(poolDataModel.reward_address),
      updateId: poolDataModel.update_id,
      vrfKeyHash: Cardano.VrfVkHex(vrfKeyHash)
    });
  });
  it('mapPoolUpdate', () => {
    expect(mapPoolUpdate(poolUpdateModel)).toEqual({
      id: poolUpdateModel.id,
      updateId: poolUpdateModel.update_id
    });
  });
  it('mapAddressOwner', () => {
    expect(mapAddressOwner(addressOwnerModel)).toEqual({
      address: Cardano.RewardAccount(addressOwnerModel.address),
      hashId: addressOwnerModel.hash_id
    });
  });
  it('mapEpochReward', () => {
    expect(mapEpochReward(epochRewardModel, hash_id)).toEqual({
      epochReward: {
        activeStake: BigInt(epochRewardModel.active_stake),
        epoch: epochRewardModel.epoch_no,
        epochLength: Number(epochRewardModel.epoch_length),
        memberROI: epochRewardModel.member_roi,
        operatorFees: BigInt(epochRewardModel.operator_fees),
        totalRewards: BigInt(epochRewardModel.total_rewards)
      },
      hashId: hash_id
    });
  });
  it('mapPoolMetrics', () => {
    expect(mapPoolMetrics(poolMetricsModel)).toEqual({
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
  });
  it('mapPoolAPY', () => {
    expect(mapPoolAPY(poolAPYModel)).toEqual({
      apy: poolAPYModel.apy,
      hashId: poolAPYModel.hash_id
    });
  });
  describe('toCoreStakePool', () => {
    const poolOwners = [mapAddressOwner(addressOwnerModel)];
    const poolDatas = [mapPoolData(poolDataModel)];
    const poolRegistrations = [mapPoolRegistration(poolRegistrationModel)];
    const poolRelays = [mapRelay(poolRelayByAddress)];
    const poolRetirements = [mapPoolRetirement(poolRetirementModel)];
    const poolRewards = [mapEpochReward(epochRewardModel, hash_id)];
    const poolMetrics = [mapPoolMetrics(poolMetricsModel)];
    const poolAPYs = [mapPoolAPY(poolAPYModel)];
    const stakePool = {
      cost: poolDatas[0].cost,
      epochRewards: poolRewards.map((r) => r.epochReward),
      hexId: poolDatas[0].hexId,
      id: poolDatas[0].id,
      margin: { denominator: 10_000, numerator: 1 },
      metadata: poolDatas[0].metadata,
      metadataJson: poolDatas[0].metadataJson,
      metrics: { ...poolMetrics[0].metrics, apy: poolAPYs[0].apy },
      owners: poolOwners.map((o) => o.address),
      pledge: poolDatas[0].pledge,
      relays: poolRelays.map((r) => r.relay),
      rewardAccount: poolDatas[0].rewardAccount,
      status: Cardano.StakePoolStatus.Retiring,
      transactions: {
        registration: poolRegistrations.map((r) => r.transactionId),
        retirement: poolRetirements.map((r) => r.transactionId)
      },
      vrf: poolDatas[0].vrfKeyHash
    } as Cardano.StakePool;
    const totalCount = 1;
    it('toCoreStakePool with retiring status', () => {
      expect(
        toCoreStakePool([poolDataModel.hash_id], {
          lastEpoch: poolRetirementModel.retiring_epoch - 1,
          poolAPYs,
          poolDatas,
          poolMetrics,
          poolOwners,
          poolRegistrations,
          poolRelays,
          poolRetirements,
          poolRewards,
          totalCount
        })
      ).toStrictEqual({ pageResults: [stakePool], totalResultCount: totalCount });
    });
    it('toCoreStakePool with retired status', () => {
      expect(
        toCoreStakePool([poolDataModel.hash_id], {
          lastEpoch: poolRetirementModel.retiring_epoch + 1,
          poolAPYs,
          poolDatas,
          poolMetrics,
          poolOwners,
          poolRegistrations,
          poolRelays,
          poolRetirements,
          poolRewards,
          totalCount
        })
      ).toStrictEqual({
        pageResults: [{ ...stakePool, status: Cardano.StakePoolStatus.Retired }],
        totalResultCount: totalCount
      });
    });
    it('toCoreStakePool with activating status', () => {
      const _retirements = [
        mapPoolRetirement({ ...poolRetirementModel, retiring_epoch: poolRegistrationModel.active_epoch_no - 1 })
      ];
      expect(
        toCoreStakePool([poolDataModel.hash_id], {
          lastEpoch: poolRegistrationModel.active_epoch_no - 1,
          poolAPYs,
          poolDatas,
          poolMetrics,
          poolOwners,
          poolRegistrations,
          poolRelays,
          poolRetirements: _retirements,
          poolRewards,
          totalCount
        })
      ).toEqual({
        pageResults: [
          {
            ...stakePool,
            status: Cardano.StakePoolStatus.Activating,
            transactions: {
              registration: poolRegistrations.map((r) => r.transactionId),
              retirement: _retirements.map((r) => r.transactionId)
            }
          }
        ],
        totalResultCount: totalCount
      });
    });
    it('toCoreStakePool with active status', () => {
      const _retirements = [
        mapPoolRetirement({ ...poolRetirementModel, retiring_epoch: poolRegistrationModel.active_epoch_no })
      ];
      expect(
        toCoreStakePool([poolDataModel.hash_id], {
          lastEpoch: poolRegistrationModel.active_epoch_no,
          poolAPYs,
          poolDatas,
          poolMetrics,
          poolOwners,
          poolRegistrations,
          poolRelays,
          poolRetirements: _retirements,
          poolRewards,
          totalCount
        })
      ).toEqual({
        pageResults: [
          {
            ...stakePool,
            status: Cardano.StakePoolStatus.Active,
            transactions: {
              registration: poolRegistrations.map((r) => r.transactionId),
              retirement: _retirements.map((r) => r.transactionId)
            }
          }
        ],
        totalResultCount: totalCount
      });
    });
  });
  it('mapPoolStats', () => {
    expect(mapPoolStats({ active: '20', retired: '0', retiring: '1' })).toEqual<StakePoolStats>({
      qty: { active: 20, retired: 0, retiring: 1 }
    });
  });
});
