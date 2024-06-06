import { Cardano } from '@cardano-sdk/core';
import { DynamicChangeAddressResolver, delegationMatchesPortfolio } from '../../../src/index.js';
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
  rewardAccount_0,
  rewardAccount_1,
  rewardAccount_2,
  rewardAccount_3
} from './testData.js';
import { logger } from '@cardano-sdk/util-dev';
import type { DelegatedStake } from '../../../src/index.js';

describe('delegationMatchesPortfolio', () => {
  const poolIds: Cardano.PoolId[] = [
    Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
    Cardano.PoolId('pool1t9xlrjyk76c96jltaspgwcnulq6pdkmhnge8xgza8ku7qvpsy9r'),
    Cardano.PoolId('pool1la4ghj4w4f8p4yk4qmx0qvqmzv6592ee9rs0vgla5w6lc2nc8w5')
  ];

  const delegation1: DelegatedStake[] = [
    {
      pool: {
        hexId: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
        status: Cardano.StakePoolStatus.Active
      }
    } as unknown as DelegatedStake,
    {
      pool: {
        hexId: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
        status: Cardano.StakePoolStatus.Active
      },
      rewardAccounts: []
    } as unknown as DelegatedStake,
    {
      pool: {
        hexId: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[2])),
        status: Cardano.StakePoolStatus.Active
      },
      rewardAccounts: []
    } as unknown as DelegatedStake
  ];

  const delegation2: DelegatedStake[] = [
    {
      pool: {
        hexId: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
        status: Cardano.StakePoolStatus.Active
      }
    } as unknown as DelegatedStake,
    {
      pool: {
        hexId: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
        status: Cardano.StakePoolStatus.Active
      },
      rewardAccounts: []
    } as unknown as DelegatedStake
  ];

  const portfolio = {
    name: 'Portfolio',
    pools: [
      {
        id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
        weight: 1
      },
      {
        id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
        weight: 1
      },
      {
        id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[2])),
        weight: 1
      }
    ]
  };

  it('returns true if portfolio matches current delegation', () => {
    expect(delegationMatchesPortfolio(portfolio, delegation1)).toBeTruthy();
  });

  it('returns false if portfolio doesnt matches current delegation', () => {
    expect(delegationMatchesPortfolio(portfolio, delegation2)).toBeFalsy();
  });
});

describe('DynamicChangeAddressResolver', () => {
  it('assigns ownership of all change outputs to the address containing the stake credential, if delegating to one pool', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId1,
            {
              percentage: Percent(0),
              pool: pool1,
              rewardAccounts: [rewardAccount_3],
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
          value: { coins: 10n }
        },
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

    expect(updatedChange).toEqual([
      { address: address_0_3, value: { coins: 10n } },
      { address: address_0_3, value: { coins: 10n } },
      { address: address_0_3, value: { coins: 10n } }
    ]);
  });

  it('adds all change outputs at payment_stake address 0 if the wallet is currently not delegating to any pool', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(new Map<Cardano.PoolId, DelegatedStake>([])).distribution$,
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
          value: { coins: 10n }
        },
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

    expect(updatedChange).toEqual([
      { address: address_0_0, value: { coins: 10n } },
      { address: address_0_0, value: { coins: 10n } },
      { address: address_0_0, value: { coins: 10n } }
    ]);
  });

  it('distributes change equally between the currently delegated addresses if no portfolio is given, ', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId1,
            {
              percentage: Percent(0),
              pool: pool1,
              rewardAccounts: [rewardAccount_1],
              stake: 0n
            }
          ],
          [
            poolId2,
            {
              percentage: Percent(0),
              pool: pool2,
              rewardAccounts: [rewardAccount_2],
              stake: 0n
            }
          ],
          [
            poolId3,
            {
              percentage: Percent(0),
              pool: pool2,
              rewardAccounts: [rewardAccount_3],
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
          value: { coins: 10n }
        },
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

    expect(updatedChange).toEqual([
      { address: address_0_3, value: { coins: 10n } },
      { address: address_0_2, value: { coins: 10n } },
      { address: address_0_1, value: { coins: 10n } }
    ]);
  });

  it('doesnt throw if there are entries with 0% in the portfolio, ', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId1,
            {
              percentage: Percent(0),
              pool: pool1,
              rewardAccounts: [rewardAccount_1],
              stake: 0n
            }
          ],
          [
            poolId2,
            {
              percentage: Percent(0),
              pool: pool2,
              rewardAccounts: [rewardAccount_2],
              stake: 0n
            }
          ],
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
          name: 'Portfolio',
          pools: [
            {
              id: pool1.hexId,
              weight: 0
            },
            {
              id: pool2.hexId,
              weight: 0
            },
            {
              id: pool3.hexId,
              weight: 1
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
        },
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 10n }
        },
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

    expect(updatedChange).toEqual([
      { address: address_0_3, value: { coins: 10n } },
      { address: address_0_3, value: { coins: 10n } },
      { address: address_0_3, value: { coins: 10n } }
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

  it('distributes change equally between the currently delegated addresses if portfolio doesnt match current delegation', async () => {
    const changeAddressResolver = new DynamicChangeAddressResolver(
      knownAddresses$,
      createMockDelegateTracker(
        new Map<Cardano.PoolId, DelegatedStake>([
          [
            poolId1,
            {
              percentage: Percent(0),
              pool: pool1,
              rewardAccounts: [rewardAccount_0],
              stake: 0n
            }
          ],
          [
            poolId2,
            {
              percentage: Percent(0),
              pool: pool2,
              rewardAccounts: [rewardAccount_1],
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
        },
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
    expect(updatedChange).toEqual([
      { address: address_0_1, value: { coins: 10n } },
      { address: address_0_0, value: { coins: 10n } }
    ]);
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
