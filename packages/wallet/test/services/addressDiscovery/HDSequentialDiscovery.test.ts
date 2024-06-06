import { AddressType, Bip32Account, KeyRole } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { HDSequentialDiscovery } from '../../../src/index.js';
import { createAsyncKeyAgent } from '../../util.js';
import {
  createMockChainHistoryProvider,
  mockAlwaysEmptyChainHistoryProvider,
  mockChainHistoryProvider
} from './mockData.js';
import type { AccountAddressDerivationPath } from '@cardano-sdk/key-management';

const asPaymentAddress = (address: string) => address as Cardano.PaymentAddress;

describe('HDSequentialDiscovery', () => {
  let bip32Account: Bip32Account;

  beforeEach(async () => {
    bip32Account = await Bip32Account.fromAsyncKeyAgent(await createAsyncKeyAgent());
    // const addresses = createStubAddresses();
    bip32Account.deriveAddress = jest
      .fn()
      .mockImplementation(async (payment: AccountAddressDerivationPath, stakeKeyIndex = 0) => ({
        accountIndex: 0,
        address: `testAddress_${payment.index}_${stakeKeyIndex}_${payment.type}` as Cardano.PaymentAddress,
        index: payment.index,
        networkId: Cardano.NetworkId.Testnet,
        rewardAccount: `testStakeAddress_${stakeKeyIndex}` as Cardano.RewardAccount,
        stakeKeyDerivationPath: {
          index: stakeKeyIndex,
          role: KeyRole.Stake
        },
        type: payment.type
      }));
  });

  it('can return both "internal" and "external" type addresses', async () => {
    const discovery = new HDSequentialDiscovery(
      createMockChainHistoryProvider(
        new Map([
          [asPaymentAddress('testAddress_0_0_0'), 1],
          [asPaymentAddress('testAddress_0_0_1'), 1],
          [asPaymentAddress('testAddress_1_0_0'), 1],
          [asPaymentAddress('testAddress_1_0_1'), 1],
          [asPaymentAddress('testAddress_2_0_0'), 1]
        ])
      ),
      25
    );

    const addresses = await discovery.discover(bip32Account);

    expect(addresses.length).toEqual(5);
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
      address: 'testAddress_0_0_1',
      index: 0,
      networkId: 0,
      rewardAccount: 'testStakeAddress_0',
      stakeKeyDerivationPath: {
        index: 0,
        role: KeyRole.Stake
      },
      type: AddressType.Internal
    });
    expect(addresses[2]).toEqual({
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
    expect(addresses[3]).toEqual({
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
    expect(addresses[4]).toEqual({
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
    expect(addresses).toEqual(
      [...addresses].sort(
        (a, b) => a.index - b.index || a.stakeKeyDerivationPath!.index - b.stakeKeyDerivationPath!.index
      )
    );
  });

  it('derives exactly 1 address when no used addresses are found', async () => {
    const discovery = new HDSequentialDiscovery(mockAlwaysEmptyChainHistoryProvider, 25);
    const addresses = await discovery.discover(bip32Account);
    expect(addresses).toHaveLength(1);
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

    const addresses = await discovery.discover(bip32Account);

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

    expect(addresses).toEqual(
      [...addresses].sort(
        (a, b) => a.index - b.index || a.stakeKeyDerivationPath!.index - b.stakeKeyDerivationPath!.index
      )
    );
  });

  it('return all discovered addresses', async () => {
    const discovery = new HDSequentialDiscovery(mockChainHistoryProvider, 25);

    const addresses = await discovery.discover(bip32Account);

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

    // The mock chain history provider will only 'return' results for even addresses which index is
    // less than 100. On top of that, the discovery process will return the addresses sorted by payment credential and
    // stake credential it will not return duplicates. We can reproduce this list from our initial data set by
    // filtering/ordering the addresses accordingly and asserting the results.
    const sorted = addresses.sort(
      (a, b) => a.index - b.index || a.stakeKeyDerivationPath!.index - b.stakeKeyDerivationPath!.index
    );

    const filtered = sorted.filter((address) => {
      const index = Number(address.address.split('_')[1]);
      return index < 100 && index % 2 === 0;
    });

    expect(addresses).toEqual(filtered);
  });
});
