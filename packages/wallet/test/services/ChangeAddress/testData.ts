import { AddressType, GroupedAddress, KeyRole } from '@cardano-sdk/key-management';
import { BehaviorSubject } from 'rxjs';
import { Cardano } from '@cardano-sdk/core';
import { DelegatedStake, RewardsHistory } from '../../../src';

const poolBase = {
  cost: 0n,
  hexId: '' as Cardano.PoolIdHex,
  id: '' as Cardano.PoolId,
  margin: {
    denominator: 0,
    numerator: 0
  },
  owners: [],
  pledge: 0n,
  relays: [],
  rewardAccount: '' as Cardano.RewardAccount,
  status: Cardano.StakePoolStatus.Active,
  vrf: '' as Cardano.VrfVkHex
};

export const poolId1 = 'pool1z5uqdk7dzdxaae5633fqfcu2eqzy3a3rgtuvy087fdld7yws0xt' as Cardano.PoolId;
export const poolHexId1 = '153806dbcd134ddee69a8c5204e38ac80448f62342f8c23cfe4b7edf' as Cardano.PoolIdHex;
export const pool1 = {
  ...poolBase,
  hexId: poolHexId1,
  id: poolId1
};

export const poolId2 = 'pool1pu5jlj4q9w9jlxeu370a3c9myx47md5j5m2str0naunn2q3lkdy' as Cardano.PoolId;
export const poolHexId2 = '0f292fcaa02b8b2f9b3c8f9fd8e0bb21abedb692a6d5058df3ef2735' as Cardano.PoolIdHex;
export const pool2 = {
  ...poolBase,
  hexId: poolHexId2,
  id: poolId2
};

export const poolId3 = 'pool1q80jjs53w0fx836n8g38gtdwr8ck5zre3da90peuxn84sj3cu0r' as Cardano.PoolId;
export const poolHexId3 = '01df29429173d263c7533a22742dae19f16a08798b7a57873c34cf58' as Cardano.PoolIdHex;
export const pool3 = {
  ...poolBase,
  hexId: poolHexId3,
  id: poolId3
};

export const poolId4 = 'pool1qqqqqdk4zhsjuxxd8jyvwncf5eucfskz0xjjj64fdmlgj735lr9' as Cardano.PoolId;
export const poolHexId4 = '00000036d515e12e18cd3c88c74f09a67984c2c279a5296aa96efe89' as Cardano.PoolIdHex;
export const pool4 = {
  ...poolBase,
  hexId: poolHexId4,
  id: poolId4
};

export const poolId5 = 'pool1fmf707pca09wmv6dc7ap4kxf0j648374ruu6ahazhpywcngt780' as Cardano.PoolId;
export const poolHexId5 = '4ed3e7f838ebcaedb34dc7ba1ad8c97cb553c7d51f39aedfa2b848ec' as Cardano.PoolIdHex;
export const pool5 = {
  ...poolBase,
  hexId: poolHexId5,
  id: poolId5
};

export const address_0_0 =
  'addr_test1qrll6whtvnuhrs72wy6eemm3r8yzzagxfqv0k06hszyv7jj2stmxyzxm30w6yvw5g8am3yelc96ev8war8c6av05t6zq404pmh' as Cardano.PaymentAddress;

export const address_0_1 =
  'addr_test1qrll6whtvnuhrs72wy6eemm3r8yzzagxfqv0k06hszyv7j30s80vtdvdv7g7agsfsun09vc0cg6ce0ewz5xfmlpsp7vqztnqau' as Cardano.PaymentAddress;

export const address_0_2 =
  'addr_test1qrll6whtvnuhrs72wy6eemm3r8yzzagxfqv0k06hszyv7j5kmfvuuyw3jxs96cf64scqkmg44pz42avalusp8jrtmk2s5dg5fm' as Cardano.PaymentAddress;

export const address_0_3 =
  'addr_test1qrll6whtvnuhrs72wy6eemm3r8yzzagxfqv0k06hszyv7j5jv96zglvh7h6udpnl8vfdrnpqyclw98duujl8et38hjvsj46dck' as Cardano.PaymentAddress;

export const address_0_4 =
  'addr_test1qrll6whtvnuhrs72wy6eemm3r8yzzagxfqv0k06hszyv7j5l20dgn23am37z6vqykk4atzuccwxrwty0adzzaawjmm9qd3hghl' as Cardano.PaymentAddress;

export const address_0_5 =
  'addr_test1qrll6whtvnuhrs72wy6eemm3r8yzzagxfqv0k06hszyv7jkae8l9chs8pzgv99ecx7x8xw83wy90nsjtcrjg03e6w8cqt9lqfj' as Cardano.PaymentAddress;

export const address_1_0 =
  'addr_test1qr3pzel9252g4unnydmkumpgw48gxsmxasvpgwkplpacgy62stmxyzxm30w6yvw5g8am3yelc96ev8war8c6av05t6zq4muu7n' as Cardano.PaymentAddress;

export const address_2_0 =
  'addr_test1qqysfpyz297r5uwp5rzamk2kyf3449mx86fkmg2nf3e3ww22stmxyzxm30w6yvw5g8am3yelc96ev8war8c6av05t6zqrcjpf2' as Cardano.PaymentAddress;

export const address_3_0 =
  'addr_test1qrywlpr30wyl0ayg295sd2d5l0a4yz549d2kzgtxctjf7q62stmxyzxm30w6yvw5g8am3yelc96ev8war8c6av05t6zqcpl38e' as Cardano.PaymentAddress;

export const address_4_0 =
  'addr_test1qzmcnd2tr4gs53lvdm800y0qatwp6z797n337k2f09pv6uz2stmxyzxm30w6yvw5g8am3yelc96ev8war8c6av05t6zq4jcqpk' as Cardano.PaymentAddress;

export const address_5_0 =
  'addr_test1qrm56gthnwrww3trxtdkkwluvt639qv7mwz4vymythqpkv62stmxyzxm30w6yvw5g8am3yelc96ev8war8c6av05t6zqpmafkk' as Cardano.PaymentAddress;

export const rewardAccount_0 =
  'stake_test1up9g9anzprdchhdzx82yr7acjvluzavkrhw3nudwk869apqf5quqh' as Cardano.RewardAccount;

export const rewardAccount_1 =
  'stake_test1uqhcrhk9kkxk0y0w5gycwfhjkv8uydvvhuhp2ryalscqlxqx36e6j' as Cardano.RewardAccount;

export const rewardAccount_2 =
  'stake_test1uztd5kwwz8gergzavya2cvqtd526s324wkwl7gqnep4am9gtw33jc' as Cardano.RewardAccount;

export const rewardAccount_3 =
  'stake_test1uzfxzapy0ktltawxselnkyk3esszv0hznk7wf0nu4cnmexgfwt2mx' as Cardano.RewardAccount;

export const rewardAccount_4 =
  'stake_test1uz048k5f4g7aclpdxqztt2743wvv8rph9j87k3pw7hfdajsrph73k' as Cardano.RewardAccount;

export const rewardAccount_5 =
  'stake_test1urwunljutcrs3yxzjuur0rrn8rchzzhecf9upey8cua8ruqswedm7' as Cardano.RewardAccount;

export const knownAddresses$ = new BehaviorSubject<GroupedAddress[]>([
  {
    accountIndex: 0,
    address: address_0_0,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_0_1,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_1,
    stakeKeyDerivationPath: { index: 1, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_0_2,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_2,
    stakeKeyDerivationPath: { index: 2, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_0_3,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_3,
    stakeKeyDerivationPath: { index: 3, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_0_4,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_4,
    stakeKeyDerivationPath: { index: 4, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_0_5,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_5,
    stakeKeyDerivationPath: { index: 5, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_1_0,
    index: 1,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_2_0,
    index: 2,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_3_0,
    index: 3,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_4_0,
    index: 4,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_5_0,
    index: 5,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  }
]);

export const unorderedKnownAddresses$ = new BehaviorSubject<GroupedAddress[]>([
  {
    accountIndex: 0,
    address: address_5_0,
    index: 5,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_1_0,
    index: 1,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_0_3,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_3,
    stakeKeyDerivationPath: { index: 3, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_0_1,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_1,
    stakeKeyDerivationPath: { index: 1, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_0_2,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_2,
    stakeKeyDerivationPath: { index: 2, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_2_0,
    index: 2,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_0_4,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_4,
    stakeKeyDerivationPath: { index: 4, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_3_0,
    index: 3,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_0_5,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_5,
    stakeKeyDerivationPath: { index: 5, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_0_0,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  },
  {
    accountIndex: 0,
    address: address_4_0,
    index: 4,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: rewardAccount_0,
    stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
    type: AddressType.External
  }
]);

export const emptyKnownAddresses$ = new BehaviorSubject<GroupedAddress[]>([]);

export const createMockDelegateTracker = (delegatedStake: Map<Cardano.PoolId, DelegatedStake>) => ({
  distribution$: new BehaviorSubject<Map<Cardano.PoolId, DelegatedStake>>(delegatedStake),
  rewardAccounts$: new BehaviorSubject<Cardano.RewardAccountInfo[]>([]),
  rewardsHistory$: new BehaviorSubject<RewardsHistory>({
    all: [],
    avgReward: null,
    lastReward: null,
    lifetimeRewards: 0n
  })
});

export const getNullDelegationPortfolio = async () => null;
