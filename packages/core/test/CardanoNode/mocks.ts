import { Cardano, Milliseconds } from '../../src/index.js';
import { Percent } from '@cardano-sdk/util';
import type { EraSummary, HealthCheckResponse, StakeDistribution } from '../../src/index.js';

const mockEraSummaries: EraSummary[] = [
  {
    parameters: { epochLength: 21_600, slotLength: Milliseconds(20_000) },
    start: { slot: 0, time: new Date(1_563_999_616_000) }
  },
  {
    parameters: { epochLength: 432_000, slotLength: Milliseconds(1000) },
    start: { slot: 1_598_400, time: new Date(1_595_964_016_000) }
  }
];

export const mockStakeDistribution: StakeDistribution = new Map([
  [
    Cardano.PoolId('pool1la4ghj4w4f8p4yk4qmx0qvqmzv6592ee9rs0vgla5w6lc2nc8w5'),
    {
      stake: { pool: 10_098_109_508n, supply: 40_453_712_883_332_027n },
      vrf: Cardano.VrfVkHex('4e4a2e82dc455449bf5f1f6d249470963cf97389b5dc4d2118fe21625f50f518')
    }
  ],
  [
    Cardano.PoolId('pool1lad5j5kawu60qljfqh02vnazxrahtaaj6cpaz4xeluw5xf023cg'),
    {
      stake: {
        pool: 14_255_969_766n,
        supply: 40_453_712_883_332_027n
      },
      vrf: Cardano.VrfVkHex('474a6d2a44b51add62d8f2fd8fe80abc722bf84478479b617ad05b39aaa84971')
    }
  ],
  [
    Cardano.PoolId('pool1llugtz5r4t6m7xz6es4qu7cszllm5y3uvx3ast5a9jzlv7h3xdu'),
    {
      stake: {
        pool: 98_763_124_501_826n,
        supply: 40_453_712_883_332_027n
      },
      vrf: Cardano.VrfVkHex('dc1c0fd7d2fd95b6e9bf0e50ab5cb722edbd7d6e85b7d53323884d429ec6a83c')
    }
  ],
  [
    Cardano.PoolId('pool1lu6ll4rcxm92059ggy6uym2p804s5hcwqyyn5vyqhy35kuxtn2f'),
    {
      stake: {
        pool: 1_494_933_206n,
        supply: 40_453_712_883_332_027n
      },
      vrf: Cardano.VrfVkHex('4a13d5e99a1868788057bf401fdb4379b7846290dd948918839981088059a564')
    }
  ]
]);

export const healthCheckResponseMock = (opts?: {
  blockNo?: number;
  slot?: number;
  hash?: string;
  networkSync?: Percent;
  withTip?: boolean;
  projectedTip?: {
    blockNo?: number;
    slot?: number;
    hash?: string;
  };
}) => ({
  localNode: {
    ledgerTip: {
      blockNo: Cardano.BlockNo(opts?.blockNo ?? 100),
      hash: Cardano.BlockId(opts?.hash ?? '9ef43ab6e234fcf90d103413096c7da752da2f45b15e1259f43d476afd12932c'),
      slot: Cardano.Slot(opts?.slot ?? 52_819_355)
    },
    networkSync: opts?.networkSync ?? Percent(0.999)
  },
  ok: true,
  ...(opts?.withTip === false
    ? undefined
    : {
        projectedTip: {
          blockNo: Cardano.BlockNo(opts?.projectedTip?.blockNo ?? 100),
          hash: Cardano.BlockId(
            opts?.projectedTip?.hash ?? '9ef43ab6e234fcf90d103413096c7da752da2f45b15e1259f43d476afd12932c'
          ),
          slot: Cardano.Slot(opts?.projectedTip?.slot ?? 52_819_355)
        }
      })
});

export const mockCardanoNode = (healthCheck?: HealthCheckResponse) => ({
  eraSummaries: jest.fn(() => Promise.resolve(mockEraSummaries)),
  healthCheck: jest.fn(() => Promise.resolve(healthCheck ?? healthCheckResponseMock())),
  initialize: jest.fn(() => Promise.resolve()),
  initializeAfter: jest.fn(() => Promise.resolve()),
  initializeBefore: jest.fn(() => Promise.resolve()),
  initializeImpl: jest.fn(() => Promise.resolve()),
  shutdown: jest.fn(() => Promise.resolve()),
  shutdownAfter: jest.fn(() => Promise.resolve()),
  shutdownBefore: jest.fn(() => Promise.resolve()),
  shutdownImpl: jest.fn(() => Promise.resolve()),
  stakeDistribution: jest.fn(() => Promise.resolve(mockStakeDistribution)),
  start: jest.fn(() => Promise.resolve()),
  startAfter: jest.fn(() => Promise.resolve()),
  startBefore: jest.fn(() => Promise.resolve()),
  startImpl: jest.fn(() => Promise.resolve()),
  systemStart: jest.fn(() => Promise.resolve(new Date(1_563_999_616_000)))
});
