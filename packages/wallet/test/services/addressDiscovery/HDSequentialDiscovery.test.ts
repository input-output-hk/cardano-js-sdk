import { AddressType, AsyncKeyAgent, KeyRole } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { HDSequentialDiscovery } from '../../../src';
import {
  createMockChainHistoryProvider,
  mockAlwaysEmptyChainHistoryProvider,
  mockAlwaysFailChainHistoryProvider,
  mockChainHistoryProvider,
  prepareMockKeyAgentWithData
} from './mockData';
import { firstValueFrom } from 'rxjs';

const asPaymentAddress = (address: string) => address as Cardano.PaymentAddress;

describe('HDSequentialDiscovery', () => {
  let mockKeyAgent: AsyncKeyAgent;

  beforeEach(() => {
    mockKeyAgent = prepareMockKeyAgentWithData();
  });

  it('can return both "internal" and "external" type addresses', async () => {
    const discovery = new HDSequentialDiscovery(
      createMockChainHistoryProvider(
        new Map([
          [asPaymentAddress('testAddress_0_0_0'), 1],
          [asPaymentAddress('testAddress_1_0_0'), 1],
          [asPaymentAddress('testAddress_1_0_1'), 1],
          [asPaymentAddress('testAddress_2_0_0'), 1]
        ])
      ),
      25
    );

    const addresses = await discovery.discover(mockKeyAgent);

    expect(addresses.length).toEqual(4);
    expect(addresses[0]).toEqual({
      accountIndex: 0,
      address: 'testAddress_0_0_0',
      index: 0,
      networkId: 0,
      rewardAccount: 'testStakeAddress_0',
      stakeKeyDerivationPath: {
        index: 0,
        role: KeyRole.Stake
      },
      type: AddressType.External
    });
    expect(addresses[1]).toEqual({
      accountIndex: 0,
      address: 'testAddress_1_0_0',
      index: 1,
      networkId: 0,
      rewardAccount: 'testStakeAddress_0',
      stakeKeyDerivationPath: {
        index: 0,
        role: KeyRole.Stake
      },
      type: AddressType.External
    });
    expect(addresses[2]).toEqual({
      accountIndex: 0,
      address: 'testAddress_1_0_1',
      index: 1,
      networkId: 0,
      rewardAccount: 'testStakeAddress_0',
      stakeKeyDerivationPath: {
        index: 0,
        role: KeyRole.Stake
      },
      type: AddressType.Internal
    });
    expect(addresses[3]).toEqual({
      accountIndex: 0,
      address: 'testAddress_2_0_0',
      index: 2,
      networkId: 0,
      rewardAccount: 'testStakeAddress_0',
      stakeKeyDerivationPath: {
        index: 0,
        role: KeyRole.Stake
      },
      type: AddressType.External
    });

    const knownAddresses = await firstValueFrom(mockKeyAgent.knownAddresses$);

    knownAddresses.sort(
      (a, b) => a.index - b.index || a.stakeKeyDerivationPath!.index - b.stakeKeyDerivationPath!.index
    );

    expect(addresses).toEqual(knownAddresses);
  });

  it('derives exactly 1 address when no used addresses are found', async () => {
    const discovery = new HDSequentialDiscovery(mockAlwaysEmptyChainHistoryProvider, 25);
    const addresses = await discovery.discover(mockKeyAgent);
    expect(addresses).toHaveLength(1);
    expect(await firstValueFrom(mockKeyAgent.knownAddresses$)).toHaveLength(1);
  });

  it('return discovered addresses with different stake keys', async () => {
    const discovery = new HDSequentialDiscovery(
      createMockChainHistoryProvider(
        new Map([
          [asPaymentAddress('testAddress_0_0_0'), 1],
          [asPaymentAddress('testAddress_0_1_0'), 1],
          [asPaymentAddress('testAddress_0_2_0'), 1],
          [asPaymentAddress('testAddress_0_3_0'), 1],
          [asPaymentAddress('testAddress_1_0_0'), 1],
          [asPaymentAddress('testAddress_2_0_0'), 1],
          [asPaymentAddress('testAddress_3_0_0'), 1],
          [asPaymentAddress('testAddress_4_0_0'), 1]
        ])
      ),
      25
    );

    const addresses = await discovery.discover(mockKeyAgent);

    // 5 payment key + 4 stake keys combined with payment index 0 (the first address overlaps in both sets).
    expect(addresses.length).toEqual(8);

    // Results are sorted by payment cred index and then stake key index.
    expect(addresses[0]).toEqual({
      accountIndex: 0,
      address: 'testAddress_0_0_0',
      index: 0,
      networkId: 0,
      rewardAccount: 'testStakeAddress_0',
      stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
      type: 0
    });

    const knownAddresses = await firstValueFrom(mockKeyAgent.knownAddresses$);

    knownAddresses.sort(
      (a, b) => a.index - b.index || a.stakeKeyDerivationPath!.index - b.stakeKeyDerivationPath!.index
    );

    expect(addresses).toEqual(knownAddresses);
  });

  it('return all discovered addresses', async () => {
    const discovery = new HDSequentialDiscovery(mockChainHistoryProvider, 25);

    const addresses = await discovery.discover(mockKeyAgent);

    expect(addresses.length).toEqual(50);

    // Results are sorted by payment cred index and then stake key index.
    expect(addresses[0]).toEqual({
      accountIndex: 0,
      address: 'testAddress_0_0_0',
      index: 0,
      networkId: 0,
      rewardAccount: 'testStakeAddress_0',
      stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
      type: 0
    });

    const knownAddresses = await firstValueFrom(mockKeyAgent.knownAddresses$);

    // The mock chain history provider will only 'return' results for even addresses which index is
    // less than 100. On top of that, the discovery process will return the addresses sorted by payment credential and
    // stake credential it will not return duplicates. We can reproduce this list from our initial data set by
    // filtering/ordering the addresses accordingly and asserting the results.
    knownAddresses.sort(
      (a, b) => a.index - b.index || a.stakeKeyDerivationPath!.index - b.stakeKeyDerivationPath!.index
    );

    const filtered = [
      ...new Set(
        knownAddresses.filter((address) => {
          const index = Number(address.address.split('_')[1]);
          return index < 100 && index % 2 === 0;
        })
      )
    ];

    expect(addresses).toEqual(filtered);
  });

  it('key agent state doesnt change if the discovery process fails', async () => {
    // Add a known address to the key agent initial state.
    const knownAddress = {
      accountIndex: 0,
      address: 'known address' as unknown as Cardano.PaymentAddress,
      index: 0,
      networkId: Cardano.NetworkId.Testnet,
      rewardAccount: 'testStakeAddress_0' as unknown as Cardano.RewardAccount,
      stakeKeyDerivationPath: {
        index: 0,
        role: KeyRole.Stake
      },
      type: AddressType.External
    };

    await mockKeyAgent.setKnownAddresses([knownAddress]);

    const discovery = new HDSequentialDiscovery(mockAlwaysFailChainHistoryProvider, 25);
    await expect(discovery.discover(mockKeyAgent)).rejects.toThrow();

    const knownAddresses = await firstValueFrom(mockKeyAgent.knownAddresses$);
    expect(knownAddresses).toEqual([knownAddress]);
  });
});
