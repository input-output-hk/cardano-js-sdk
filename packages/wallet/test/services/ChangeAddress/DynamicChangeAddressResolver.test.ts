import { Cardano } from '@cardano-sdk/core';
import { DelegatedStake, DynamicChangeAddressResolver } from '../../../src';
import { InvalidStateError, Percent } from '@cardano-sdk/util';
import {
  address_0_0,
  address_0_1,
  address_0_2,
  address_0_3,
  createMockDelegateTracker,
  emptyKnownAddresses$,
  getNullDelegationPortfolio,
  knownAddresses$,
  pool1,
  pool2,
  pool3,
  pool4,
  poolHexId1,
  poolHexId2,
  poolHexId3,
  poolHexId4,
  poolId1,
  poolId2,
  poolId3,
  poolId4,
  rewardAccount_1,
  rewardAccount_2,
  rewardAccount_3
} from './testData';
import { logger } from '@cardano-sdk/util-dev';

describe('DynamicChangeAddressResolver', () => {
  it('resolves to the first address in the knownAddresses if no portfolio is given', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId1,
            {
              percentage: Percent(0),
              pool: pool1,
              rewardAccounts: [],
              stake: 0n
            }
          ]
        ])
      ).distribution$,
      getNullDelegationPortfolio,
      logger
    );

    const selection = {
      change: [
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 10n }
        },
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 20n }
        },
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 30n }
        }
      ],
      fee: 0n,
      inputs: new Set<Cardano.Utxo>(),
      outputs: new Set<Cardano.TxOut>()
    };

    const updatedChange = await changeAddressResolver.resolve(selection);
    expect(updatedChange).toEqual([
      { address: address_0_0, value: { coins: 10n } },
      { address: address_0_0, value: { coins: 20n } },
      { address: address_0_0, value: { coins: 30n } }
    ]);
  });

  it('throws InvalidStateError if the there are no known addresses', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      emptyKnownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId1,
            {
              percentage: Percent(0),
              pool: pool1,
              rewardAccounts: [],
              stake: 0n
            }
          ]
        ])
      ).distribution$,
      getNullDelegationPortfolio,
      logger
    );

    const selection = {
      change: [
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 10n }
        },
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 20n }
        },
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 30n }
        }
      ],
      fee: 0n,
      inputs: new Set<Cardano.Utxo>(),
      outputs: new Set<Cardano.TxOut>()
    };

    await expect(changeAddressResolver.resolve(selection)).rejects.toThrow(
      new InvalidStateError('The wallet has no known addresses.')
    );
  });

  it('resolves to the first address in the knownAddresses if portfolio doesnt match current delegation', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId1,
            {
              percentage: Percent(0),
              pool: pool1,
              rewardAccounts: [],
              stake: 0n
            }
          ],
          [
            poolId2,
            {
              percentage: Percent(0),
              pool: pool2,
              rewardAccounts: [],
              stake: 0n
            }
          ]
        ])
      ).distribution$,
      () =>
        Promise.resolve({
          name: 'Test Portfolio',
          pools: [
            {
              id: poolHexId3,
              weight: 0.3
            }
          ]
        }),
      logger
    );

    const selection = {
      change: [
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 10n }
        }
      ],
      fee: 0n,
      inputs: new Set<Cardano.Utxo>(),
      outputs: new Set<Cardano.TxOut>()
    };

    const updatedChange = await changeAddressResolver.resolve(selection);
    expect(updatedChange).toEqual([{ address: address_0_0, value: { coins: 10n } }]);
  });

  it('delegates to a single reward account', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId3,
            {
              percentage: Percent(0),
              pool: pool3,
              rewardAccounts: [rewardAccount_3],
              stake: 0n
            }
          ]
        ])
      ).distribution$,
      () =>
        Promise.resolve({
          name: 'Delegate to pool 3',
          pools: [
            {
              id: poolHexId3,
              weight: 0.3
            }
          ]
        }),
      logger
    );

    const selection = {
      change: [
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 10n }
        }
      ],
      fee: 0n,
      inputs: new Set<Cardano.Utxo>(),
      outputs: new Set<Cardano.TxOut>()
    };

    const updatedChange = await changeAddressResolver.resolve(selection);
    expect(updatedChange).toEqual([{ address: address_0_3, value: { coins: 10n } }]);
  });

  it('apply changes present in the selection to determine how to distribute change', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId1,
            {
              percentage: Percent(0.33),
              pool: pool1,
              rewardAccounts: [rewardAccount_1],
              stake: 333n
            }
          ],
          [
            poolId2,
            {
              percentage: Percent(0.33),
              pool: pool2,
              rewardAccounts: [rewardAccount_2],
              stake: 333n
            }
          ],
          [
            poolId3,
            {
              percentage: Percent(0.33),
              pool: pool3,
              rewardAccounts: [rewardAccount_3],
              stake: 334n
            }
          ]
        ])
      ).distribution$,
      () =>
        Promise.resolve({
          name: 'Delegate to pool 3',
          pools: [
            {
              id: poolHexId1,
              weight: 0.33
            },
            {
              id: poolHexId2,
              weight: 0.33
            },
            {
              id: poolHexId3,
              weight: 0.33
            }
          ]
        }),
      logger
    );

    const selection = {
      change: [
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 223n }
        }
      ],
      fee: 10n,
      inputs: new Set<Cardano.Utxo>([
        [
          {
            address: address_0_2,
            index: 0,
            txId: '' as Cardano.TransactionId
          },
          {
            address: address_0_2,
            value: { coins: 333n }
          }
        ]
      ]),
      outputs: new Set<Cardano.TxOut>([
        {
          address: 'unknown' as Cardano.PaymentAddress,
          value: { coins: 100n }
        }
      ])
    };

    const updatedChange = await changeAddressResolver.resolve(selection);
    expect(updatedChange).toEqual([{ address: address_0_2, value: { coins: 223n } }]);
  });

  it('distribute multiple change outputs following the expected proportions', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId1,
            {
              percentage: Percent(0.2),
              pool: pool1,
              rewardAccounts: [rewardAccount_1],
              stake: 2000n
            }
          ],
          [
            poolId2,
            {
              percentage: Percent(0.1),
              pool: pool2,
              rewardAccounts: [rewardAccount_2],
              stake: 1000n
            }
          ],
          [
            poolId3,
            {
              percentage: Percent(0.6),
              pool: pool3,
              rewardAccounts: [rewardAccount_3],
              stake: 6000n
            }
          ]
        ])
      ).distribution$,
      () =>
        Promise.resolve({
          name: 'Delegate to pools',
          pools: [
            {
              id: poolHexId1,
              weight: 0.33
            },
            {
              id: poolHexId2,
              weight: 0.33
            },
            {
              id: poolHexId3,
              weight: 0.33
            }
          ]
        }),
      logger
    );

    const selection = {
      change: new Array<Cardano.TxOut>(),
      fee: 0n,
      inputs: new Set<Cardano.Utxo>(),
      outputs: new Set<Cardano.TxOut>()
    };

    // Add 9 change outputs
    selection.change = [1000n, 1000n, 1000n, 1000n, 1000n, 1000n, 1000n, 1000n, 1000n].map((amount) => ({
      address: '_' as Cardano.PaymentAddress,
      value: { coins: amount }
    }));

    const updatedChange = await changeAddressResolver.resolve(selection);

    expect(updatedChange).toEqual([
      { address: address_0_2, value: { coins: 1000n } },
      { address: address_0_2, value: { coins: 1000n } },
      { address: address_0_2, value: { coins: 1000n } },
      { address: address_0_2, value: { coins: 1000n } },
      { address: address_0_2, value: { coins: 1000n } },
      { address: address_0_1, value: { coins: 1000n } },
      { address: address_0_1, value: { coins: 1000n } },
      { address: address_0_1, value: { coins: 1000n } },
      { address: address_0_1, value: { coins: 1000n } }
    ]);
  });

  it('throws InvalidStateError if delegation doesnt contain any reward accounts', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId4,
            {
              percentage: Percent(0),
              pool: pool4,
              rewardAccounts: [],
              stake: 0n
            }
          ]
        ])
      ).distribution$,
      () =>
        Promise.resolve({
          name: 'Delegate to pool 4',
          pools: [
            {
              id: poolHexId4,
              weight: 0.3
            }
          ]
        }),
      logger
    );

    const selection = {
      change: [
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 10n }
        }
      ],
      fee: 0n,
      inputs: new Set<Cardano.Utxo>(),
      outputs: new Set<Cardano.TxOut>()
    };

    await expect(changeAddressResolver.resolve(selection)).rejects.toThrow(
      new InvalidStateError(`No reward accounts delegating to pool '${poolId4}'.`)
    );
  });

  it('throws InvalidStateError if delegation contains an unknown reward account', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId4,
            {
              percentage: Percent(0),
              pool: pool4,
              rewardAccounts: ['_' as Cardano.RewardAccount],
              stake: 0n
            }
          ]
        ])
      ).distribution$,
      () =>
        Promise.resolve({
          name: 'Unknown',
          pools: [
            {
              id: poolHexId4,
              weight: 0.3
            }
          ]
        }),
      logger
    );

    const selection = {
      change: [
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 10n }
        }
      ],
      fee: 0n,
      inputs: new Set<Cardano.Utxo>(),
      outputs: new Set<Cardano.TxOut>()
    };

    await expect(changeAddressResolver.resolve(selection)).rejects.toThrow(
      new InvalidStateError("Reward account '_' unknown.")
    );
  });
});
