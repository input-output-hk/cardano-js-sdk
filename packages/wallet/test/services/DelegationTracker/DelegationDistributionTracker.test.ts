import { AddressType, GroupedAddress } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { DelegatedStake, TransactionalObservables, UtxoTracker } from '../../../src';
import { EMPTY, Observable, map } from 'rxjs';
import { Percent } from '@cardano-sdk/util';
import { createDelegationDistributionTracker } from '../../../src/services/DelegationTracker/DelegationDistributionTracker';
import { createTestScheduler, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { stakeKeyDerivationPath } from '../../../../key-management/test/mocks';

describe('createDelegationDistributionTracker', () => {
  let rewardAccounts: Cardano.RewardAccountInfo[];
  let knownAddresses: GroupedAddress[];
  let pools: Cardano.StakePool[];
  let utxos: Cardano.Utxo[];

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const getTransactionalObservableMock = <T>(o$: Observable<T>): TransactionalObservables<T> => ({
    available$: o$,
    total$: o$,
    unspendable$: EMPTY
  });

  beforeEach(() => {
    pools = mocks.generateStakePools(2);
    pools[0] = { ...pools[0], id: Cardano.PoolId('pool1la4ghj4w4f8p4yk4qmx0qvqmzv6592ee9rs0vgla5w6lc2nc8w5') };
    pools[1] = { ...pools[0], id: Cardano.PoolId('pool1lad5j5kawu60qljfqh02vnazxrahtaaj6cpaz4xeluw5xf023cg') };

    utxos = mocks.utxo.slice(0, 2);
    utxos[0][1].value.coins = 454_000_000n;
    utxos[1][1].value.coins = 544_000_000n;
    // Second utxo should belong to the second address
    utxos[1][1].address = Cardano.PaymentAddress(
      'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
    );

    rewardAccounts = [
      {
        address: mocks.rewardAccount,
        delegatee: {
          currentEpoch: undefined,
          nextEpoch: undefined,
          nextNextEpoch: pools[0] as Cardano.StakePool
        },
        credentialStatus: Cardano.StakeCredentialStatus.Registered,
        rewardBalance: 1_000_000n
      },
      {
        address: Cardano.RewardAccount('stake_test1upx9faamuf54pm7alg4lna5l7ll08pz833rj45tgr9m2jyceasqjt'),
        delegatee: {
          currentEpoch: undefined,
          nextEpoch: undefined,
          nextNextEpoch: pools[1] as Cardano.StakePool
        },
        credentialStatus: Cardano.StakeCredentialStatus.Registered,
        rewardBalance: 1_000_000n
      }
    ];
    knownAddresses = [
      {
        accountIndex: 0,
        address: mocks.utxo[0][1].address,
        index: 0,
        networkId: Cardano.NetworkId.Testnet,
        rewardAccount: mocks.rewardAccount,
        stakeKeyDerivationPath,
        type: AddressType.External
      },
      {
        accountIndex: 0,
        address: utxos[1][1].address,
        index: 0,
        networkId: Cardano.NetworkId.Testnet,
        rewardAccount: rewardAccounts[1].address,
        stakeKeyDerivationPath,
        type: AddressType.External
      }
    ];
  });

  it('does not include reward accounts that are not staked', () => {
    createTestScheduler().run(({ expectObservable, cold }) => {
      rewardAccounts[0].credentialStatus = Cardano.StakeCredentialStatus.Unregistered;
      const rewardAccounts$ = cold('a', { a: [rewardAccounts[0]] });
      const knownAddresses$ = cold('a', { a: [knownAddresses[0]] as GroupedAddress[] });
      const utxoTracker: UtxoTracker = getTransactionalObservableMock(
        cold('a', { a: [utxos[0]] })
      ) as unknown as UtxoTracker;
      const delegationDistribution$ = createDelegationDistributionTracker({
        knownAddresses$,
        rewardAccounts$,
        utxoTracker
      });
      expectObservable(delegationDistribution$.pipe(map((distribution) => [...distribution.values()]))).toBe('a', {
        a: []
      });
    });
  });

  it('emits delegation distribution based on delegated account', () => {
    createTestScheduler().run(({ expectObservable, cold }) => {
      const rewardAccounts$ = cold('a', { a: [rewardAccounts[0]] });
      const knownAddresses$ = cold('a', { a: [knownAddresses[0]] as GroupedAddress[] });
      const utxoTracker: UtxoTracker = getTransactionalObservableMock(
        cold('a', { a: [utxos[0]] })
      ) as unknown as UtxoTracker;

      const delegationDistribution$ = createDelegationDistributionTracker({
        knownAddresses$,
        rewardAccounts$,
        utxoTracker
      });
      const [pool] = pools;
      expectObservable(delegationDistribution$.pipe(map((distribution) => [...distribution.values()]))).toBe('a', {
        a: [
          {
            percentage: Percent(1),
            pool,
            rewardAccounts: [rewardAccounts[0].address],
            stake: utxos[0][1].value.coins + rewardAccounts[0].rewardBalance
          } as DelegatedStake
        ]
      });
    });
  });

  it('emits delegation distribution when the same stake key is used for multiple addresses', () => {
    createTestScheduler().run(({ expectObservable, cold }) => {
      const groupedAddr1: GroupedAddress = knownAddresses[0];
      const groupedAddr2: GroupedAddress = { ...knownAddresses[1], rewardAccount: groupedAddr1.rewardAccount };
      const rewardAccounts$ = cold('a', { a: [rewardAccounts[0]] });
      const knownAddresses$ = cold('a', { a: [groupedAddr1, groupedAddr2] });
      const utxoTracker: UtxoTracker = getTransactionalObservableMock(
        cold('a', { a: utxos })
      ) as unknown as UtxoTracker;

      const delegationDistribution$ = createDelegationDistributionTracker({
        knownAddresses$,
        rewardAccounts$,
        utxoTracker
      });
      const [pool] = pools;
      expectObservable(delegationDistribution$.pipe(map((distribution) => [...distribution.values()]))).toBe('a', {
        a: [
          {
            percentage: Percent(1),
            pool,
            rewardAccounts: [rewardAccounts[0].address],
            stake: utxos[0][1].value.coins + rewardAccounts[0].rewardBalance + utxos[1][1].value.coins
          } as DelegatedStake
        ]
      });
    });
  });

  it('does not include reward accounts not delegated in nextNextEpoch', () => {
    createTestScheduler().run(({ expectObservable, cold }) => {
      rewardAccounts[0].delegatee!.nextNextEpoch = undefined;
      const rewardAccounts$ = cold('a', { a: [rewardAccounts[0]] });
      const knownAddresses$ = cold('a', { a: [knownAddresses[0]] as GroupedAddress[] });
      const utxoTracker: UtxoTracker = getTransactionalObservableMock(
        cold('a', { a: [utxos[0]] })
      ) as unknown as UtxoTracker;
      const delegationDistribution$ = createDelegationDistributionTracker({
        knownAddresses$,
        rewardAccounts$,
        utxoTracker
      });
      expectObservable(delegationDistribution$.pipe(map((distribution) => [...distribution.values()]))).toBe('a', {
        a: []
      });
    });
  });

  it('aggregates delegations by pool id', () => {
    createTestScheduler().run(({ expectObservable, cold }) => {
      const [pool] = pools;
      const [rewardAccountInfo1, rewardAccountInfo2] = rewardAccounts;
      // Second reward account is delegated to the same pool
      rewardAccountInfo2.delegatee!.nextNextEpoch = pool;

      const [knownAddr1, knownAddr2] = knownAddresses;

      const [utxo1, utxo2] = utxos;
      // Set txOut address to the second derived address so the utxo funds are allocated to it
      utxo2[1].address = knownAddr2.address;

      const rewardAccounts$ = cold('a', { a: [rewardAccountInfo1, rewardAccountInfo2] });
      const knownAddresses$ = cold('a', { a: [knownAddr1, knownAddr2] as GroupedAddress[] });
      const utxoTracker: UtxoTracker = getTransactionalObservableMock(
        cold('a', { a: [utxo1, utxo2] })
      ) as unknown as UtxoTracker;
      const delegationDistribution$ = createDelegationDistributionTracker({
        knownAddresses$,
        rewardAccounts$,
        utxoTracker
      });

      expectObservable(delegationDistribution$.pipe(map((distribution) => [...distribution.values()]))).toBe('a', {
        a: [
          {
            percentage: Percent(1),
            pool,
            rewardAccounts: [rewardAccountInfo1.address, rewardAccountInfo2.address],
            stake:
              utxo1[1].value.coins +
              utxo2[1].value.coins +
              rewardAccounts[0].rewardBalance +
              rewardAccounts[1].rewardBalance
          } as DelegatedStake
        ]
      });
    });
  });

  it('emits delegation distribution when reward accounts are delegated to separate pools', () => {
    createTestScheduler().run(({ expectObservable, cold }) => {
      const rewardAccounts$ = cold('a', { a: rewardAccounts });
      const knownAddresses$ = cold('a', { a: knownAddresses });
      const [utxo1, utxo2] = utxos;
      const utxoTracker: UtxoTracker = getTransactionalObservableMock(
        cold('a', { a: utxos })
      ) as unknown as UtxoTracker;

      const delegationDistribution$ = createDelegationDistributionTracker({
        knownAddresses$,
        rewardAccounts$,
        utxoTracker
      });
      const [pool1, pool2] = pools;
      const expectedDelegationDistribution: DelegatedStake[] = [
        {
          percentage: Percent(0.455),
          pool: pool1,
          rewardAccounts: [rewardAccounts[0].address],
          stake: utxo1[1].value.coins + rewardAccounts[0].rewardBalance
        },
        {
          percentage: Percent(0.545),
          pool: pool2,
          rewardAccounts: [rewardAccounts[1].address],
          stake: utxo2[1].value.coins + rewardAccounts[1].rewardBalance
        }
      ];
      expectObservable(delegationDistribution$.pipe(map((distribution) => [...distribution.values()]))).toBe('a', {
        a: expectedDelegationDistribution
      });
    });
  });

  it('can have staked percentages under 100 when an addresses is not delegated', () => {
    createTestScheduler().run(({ expectObservable, cold }) => {
      const rewardAccounts$ = cold('a', { a: rewardAccounts });
      const knownAddresses$ = cold('a', { a: knownAddresses });
      const [utxo1, utxo2] = utxos;
      // utxo3 has funds that do not belong to either reward addresses
      const utxo3: Cardano.Utxo = [
        {},
        { address: 'abc' as Cardano.PaymentAddress, value: { coins: 20_000_000n } }
      ] as Cardano.Utxo;
      utxo1[1].value.coins = 38_000_000n;
      utxo2[1].value.coins = 40_000_000n;

      const utxoTracker: UtxoTracker = getTransactionalObservableMock(
        cold('a', { a: [...utxos, utxo3] })
      ) as unknown as UtxoTracker;

      const delegationDistribution$ = createDelegationDistributionTracker({
        knownAddresses$,
        rewardAccounts$,
        utxoTracker
      });
      const [pool1, pool2] = pools;
      const expectedDelegationDistribution: DelegatedStake[] = [
        {
          percentage: Percent(0.39),
          pool: pool1,
          rewardAccounts: [rewardAccounts[0].address],
          stake: utxo1[1].value.coins + rewardAccounts[0].rewardBalance
        },
        {
          percentage: Percent(0.41),
          pool: pool2,
          rewardAccounts: [rewardAccounts[1].address],
          stake: utxo2[1].value.coins + rewardAccounts[1].rewardBalance
        }
      ];
      expectObservable(delegationDistribution$.pipe(map((distribution) => [...distribution.values()]))).toBe('a', {
        a: expectedDelegationDistribution
      });
    });
  });

  it('updates stake distribution when a new stake key is delegated', () => {
    createTestScheduler().run(({ expectObservable, cold }) => {
      const rewardAccounts$ = cold('ab', {
        a: [rewardAccounts[0], { ...rewardAccounts[1], credentialStatus: Cardano.StakeCredentialStatus.Unregistered }],
        b: rewardAccounts
      });
      const knownAddresses$ = cold('a', { a: knownAddresses });
      const [utxo1, utxo2] = utxos;

      const utxoTracker: UtxoTracker = getTransactionalObservableMock(
        cold('a', { a: utxos })
      ) as unknown as UtxoTracker;

      const delegationDistribution$ = createDelegationDistributionTracker({
        knownAddresses$,
        rewardAccounts$,
        utxoTracker
      });
      const [pool1, pool2] = pools;
      const expectedDistribution1Pool: DelegatedStake[] = [
        {
          percentage: Percent(0.455),
          pool: pool1,
          rewardAccounts: [rewardAccounts[0].address],
          stake: utxo1[1].value.coins + rewardAccounts[0].rewardBalance
        }
      ];
      const expectedDistribution2Pools: DelegatedStake[] = [
        {
          percentage: Percent(0.455),
          pool: pool1,
          rewardAccounts: [rewardAccounts[0].address],
          stake: utxo1[1].value.coins + rewardAccounts[0].rewardBalance
        },
        {
          percentage: Percent(0.545),
          pool: pool2,
          rewardAccounts: [rewardAccounts[1].address],
          stake: utxo2[1].value.coins + rewardAccounts[1].rewardBalance
        }
      ];
      expectObservable(delegationDistribution$.pipe(map((distribution) => [...distribution.values()]))).toBe('ab', {
        a: expectedDistribution1Pool,
        b: expectedDistribution2Pools
      });
    });
  });

  it('recalculates stake distribution on utxo changes', () => {
    createTestScheduler().run(({ expectObservable, cold }) => {
      const [utxo1, utxo2] = utxos;

      // 2nd known address receives one more utxo
      const utxo3: Cardano.Utxo = [{ ...utxo2[0] }, { ...utxo2[1], value: { coins: 100_000_000n } }];

      const rewardAccounts$ = cold('a', { a: rewardAccounts });
      const knownAddresses$ = cold('a', { a: knownAddresses });
      const utxoTrackerMock = cold('ab', { a: utxos, b: [...utxos, utxo3] });

      const utxoTracker: UtxoTracker = getTransactionalObservableMock(utxoTrackerMock) as unknown as UtxoTracker;

      const delegationDistribution$ = createDelegationDistributionTracker({
        knownAddresses$,
        rewardAccounts$,
        utxoTracker
      });
      const [pool1, pool2] = pools;
      const expectedDelegationDistribution: DelegatedStake[] = [
        {
          percentage: Percent(0.455),
          pool: pool1,
          rewardAccounts: [rewardAccounts[0].address],
          stake: utxo1[1].value.coins + rewardAccounts[0].rewardBalance
        },
        {
          percentage: Percent(0.545),
          pool: pool2,
          rewardAccounts: [rewardAccounts[1].address],
          stake: utxo2[1].value.coins + rewardAccounts[1].rewardBalance
        }
      ];

      // New stakes after total balance increases by 100ada.
      // Since utxo3 was not registered in the second account yet,
      // the two accounts must add up to 90% (1000/1100)
      const expectedDelegationDistribution2: DelegatedStake[] = [
        { ...expectedDelegationDistribution[0], percentage: Percent(455 / 1100) },
        { ...expectedDelegationDistribution[1], percentage: Percent(545 / 1100) }
      ];

      // New balances after second address gets utxo3: [455ada, 645ada]
      const expectedDelegationDistribution3: DelegatedStake[] = [
        { ...expectedDelegationDistribution[0], percentage: Percent(455 / 1100) },
        {
          ...expectedDelegationDistribution[1],
          percentage: Percent(645 / 1100),
          stake: expectedDelegationDistribution[1].stake + utxo3[1].value.coins
        }
      ];

      expectObservable(delegationDistribution$.pipe(map((distribution) => [...distribution.values()]))).toBe('a(bc)', {
        a: expectedDelegationDistribution,
        b: expectedDelegationDistribution2,
        c: expectedDelegationDistribution3
      });
    });
  });
});
