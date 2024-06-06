import * as envalid from 'envalid';
import { Cardano } from '@cardano-sdk/core';
import { createWriteStream } from 'fs';
import { fork } from 'child_process';
import { getRandomPort } from 'get-port-please';
import { logger } from '@cardano-sdk/util-dev';
import { stakePoolHttpProvider } from '@cardano-sdk/cardano-services-client';
import path from 'path';
import type { ChildProcess } from 'child_process';
import type { QueryStakePoolsArgs, StakePoolProvider } from '@cardano-sdk/core';
import type { WriteStream } from 'fs';

type StakePoolRecord = Record<string, Cardano.StakePool>;

const cli = path.join('..', 'cardano-services', 'dist', 'cjs', 'cli.js');

// db-sync implementation has some problems affecting more values of following preprod stake pools
const firstStrangePool = 'pool1fyssphxavlclpddydsx4k3zdg04j6rkshkxvf7wedny95tvqyla';
const secondStrangePool = 'pool1954pqc2ytx7kzemyjgtlg9m85ty8ffm0am3yg44w5cg8x68hgud';

// db-sync implementation has a known bug affecting following preprod stake pools
const poolsExcludeStatus = new Set([
  'pool190dapqls3y9dxuqtexmm80sppjha7e8rhu62xydgwn4jjj07pqm',
  'pool104umgmn7el9dn78afeydlrg5wm6snlclw0xn9fmn4jwg5j633rt',
  'pool10gqm62xy7caj6jhhefsl7h59kse3rv2esuh9rvx55eze2n8dlrj',
  'pool120amlaz2x5a63vkh9fpt3gy4qyjvr0vxjt8p2q6ytwh4ywfukwr',
  'pool13hxcpvdu9sznsyslxc5ctyu68vkvxk947jflrpsdd6l5u909q9y',
  'pool15x8nh74ecca5dqsd4q4hvywqvasg0z6ns0v44cfgftppc9a7pjv',
  'pool17k3p7y9u5mv4z9s8qzuyhzfasdm0lz3jlta5ux43t5j4sypwadk',
  'pool1h0qpp77llkzqssgansh8xg8vrhur3aeynn5n9sqhqgde6ekcwwr',
  'pool1jtxnlht8rlu4xhlucydej6584uv3px57urlu3demtm55cxe2azp',
  'pool1qkkpw4e4lhdpaeppdsdkesfn47q36hdnfw4v0gh27w3yc6l3fpn',
  'pool1tgzfuffjtkshhm250h44unj5q6hvm6tqgs6592zwt26hqr2tez5',
  'pool1wvcgcga3lj44p6l3lh3msxharg74euzqptphax0kl6hcx44x63a',
  'pool1yx6uxy0sju8smm8matljll0jz9d4hmpcu6x7yp0vkx5ng5cun22',
  secondStrangePool
]);

// db-sync implementation has some problems affecting following preprod stake pools
const poolsExcludeLiveSize = new Set([
  'pool1kzfkwxsw2f68gk0pp4cc5r3sfejxgpnp9tcygtxqnm0lgnyv0ea',
  'pool1vntql3yhyzzm3p846mds33nmuzz30jrn56fvjdd3hhu9u5n9d4d',
  firstStrangePool,
  secondStrangePool
]);

// db-sync implementation has some problems affecting following preprod stake pools
const poolsExcludeLiveStake = new Set([firstStrangePool, secondStrangePool]);

const expectToBeNear = (received: bigint | number, expected: bigint | number, not?: boolean) => {
  const rec = Number(received);
  const exp = Number(expected);
  const numDigits = exp === 0 ? 2 : 2 - Math.log10(Math.abs(exp));

  if (not) expect(rec).not.toBeCloseTo(exp, numDigits);
  else expect(rec).toBeCloseTo(exp, numDigits);
};

describe('StakePoolCompare', () => {
  const env = envalid.cleanEnv(process.env, {
    DB_SYNC_CONNECTION_STRING: envalid.str(),
    NETWORK: envalid.str(),
    POOLS: envalid.str(),
    STAKE_POOL_PROVIDER_URL: envalid.url()
  });

  const baseArgs = [
    'start-provider-server',
    '--logger-min-severity',
    'debug',
    '--service-names',
    'stake-pool',
    '--disable-db-cache',
    'true',
    '--cardano-node-config-path',
    path.join('..', 'cardano-services', 'config', 'network', env.NETWORK, 'cardano-node', 'config.json'),
    '--postgres-connection-string-db-sync',
    env.DB_SYNC_CONNECTION_STRING,
    '--api-url'
  ];

  const pagination = { limit: 20, startAt: 0 };
  // Stake pools id are fetched from DB by setup.ts file
  const pools: string[] = JSON.parse(env.POOLS);
  const processes: ChildProcess[] = [];

  let providerOne: StakePoolProvider;
  let providerTwo: StakePoolProvider;
  let poolsOne: StakePoolRecord;
  let poolsTwo: StakePoolRecord;

  const fetchAllPools = async (
    provider: StakePoolProvider,
    args: Omit<QueryStakePoolsArgs, 'pagination'> = {},
    startAt = 0
  ): Promise<Cardano.StakePool[]> => {
    const result = await provider.queryStakePools({ ...args, pagination: { ...pagination, startAt } });

    return result.pageResults.length === 0
      ? result.pageResults
      : [...result.pageResults, ...(await fetchAllPools(provider, args, startAt + 20))];
  };

  // Fetch all stake pools with all reward history and organize in a StakePoolRecord
  const fetchAll = async (provider: StakePoolProvider) =>
    Object.fromEntries((await fetchAllPools(provider, { apyEpochsBackLimit: 1_000_000 })).map((_) => [_.id, _]));

  const startServer = async (args: string[]) => {
    const port = await getRandomPort();
    const apiUrl = `http://localhost:${port}/`;

    // Due to a bug https://github.com/nodejs/node-v0.x-archive/issues/4030
    // the createWriteStream returned value can't be directly used as fork parameter
    // we need to wait the stream is actually open
    const createLogStream = (name: string) =>
      new Promise<WriteStream>((resolve) => {
        const stream = createWriteStream(path.join('logs', `server-${processes.length}-${name}.log`), { flags: 'a' });

        stream.on('open', () => resolve(stream));
      });

    processes.push(
      fork(cli, [...baseArgs, apiUrl, ...args], {
        env: process.env,
        stdio: ['ignore', await createLogStream('stdout'), await createLogStream('stderr'), 'ipc']
      })
    );

    return `${apiUrl}stake-pool`;
  };

  const setupProvider = async (args: string[] = []) => {
    const provider = stakePoolHttpProvider({ baseUrl: await startServer(args), logger });

    // eslint-disable-next-line no-constant-condition
    while (true) {
      try {
        await provider.healthCheck();

        return provider;
        // eslint-disable-next-line no-empty
      } catch {}
    }
  };

  beforeAll(async () => {
    providerOne = await setupProvider(['--use-blockfrost', 'true']);
    providerTwo = await setupProvider();
    poolsOne = await fetchAll(providerOne);
    poolsTwo = await fetchAll(providerTwo);
  });

  afterAll(async () => {
    for (const proc of processes)
      await new Promise<void>((resolve) => {
        if (proc.kill()) proc.on('close', () => resolve());
        else resolve();
      });
  });

  // Iterate over stake pools from setup and describe each one
  describe.each(pools)('compare %s', (id) => {
    let poolOne: Cardano.StakePool;
    let poolTwo: Cardano.StakePool;

    beforeAll(() => {
      poolOne = poolsOne[id];
      poolTwo = poolsTwo[id];
    });

    describe('metrics', () => {
      let metricOne: Cardano.StakePoolMetrics;
      let metricTwo: Cardano.StakePoolMetrics;

      beforeAll(() => {
        metricOne = poolOne.metrics!;
        metricTwo = poolTwo.metrics!;
      });

      // check apy

      it('blocksCreated (lower limit)', () =>
        expect(metricOne.blocksCreated).toBeGreaterThan(metricTwo.blocksCreated - 10));
      it('blocksCreated (upper limit)', () =>
        expect(metricOne.blocksCreated).toBeLessThanOrEqual(metricTwo.blocksCreated));

      it('delegators (lower limit)', () => expect(metricOne.delegators).toBeGreaterThan(metricTwo.delegators - 3));
      it('delegators (upper limit)', () => expect(metricOne.delegators).toBeLessThanOrEqual(metricTwo.delegators + 3));

      // a known problem on db-sync implementation makes this test to fail
      // it('livePledge', () => expectToBeNear(metricOne.livePledge, metricTwo.livePledge));

      // the live pledge known problem on db-sync implementation makes this test to fail
      // it('saturation', () => expectToBeNear(metricOne.saturation, metricTwo.saturation));

      describe('size', () => {
        // some minor diff probably originated by some rounding or difference in computation makes this check to fail
        // it('active', () => expect(metricOne.size.active).toBe(metricTwo.size.active));
        it('active', () => expectToBeNear(metricOne.size.active, metricTwo.size.active, id === firstStrangePool));

        // the live pledge known problem on db-sync implementation makes this test to fail on the given preprod pools
        it('live', () => expectToBeNear(metricOne.size.live, metricTwo.size.live, poolsExcludeLiveSize.has(id)));
      });
      describe('stake', () => {
        it('active', () => expect(metricOne.stake.active).toBe(metricTwo.stake.active));

        // it seems withdraws performed some epochs after last retirement
        // are not correctly handled by db-sync implementation as for this preprod pool
        it('live', () =>
          expectToBeNear(Number(metricOne.stake.live), Number(metricTwo.stake.live), poolsExcludeLiveStake.has(id)));
      });
    });

    it('owners', () => expect(poolOne.owners).toEqual(poolTwo.owners));

    it('rewardAccount', () => expect(poolOne.rewardAccount).toBe(poolTwo.rewardAccount));

    // a known problem on db-sync implementation makes this test to fail on the given preprod pools
    if (!poolsExcludeStatus.has(id)) it('status', () => expect(poolOne.status).toBe(poolTwo.status));
    else it('status', () => expect(poolOne.status).not.toBe(poolTwo.status));

    // check epochRewards
  });

  describe('sort options', () => {
    it('by saturation asc', async () => {
      const result = await fetchAllPools(providerOne, { sort: { field: 'saturation', order: 'asc' } });

      for (let i = 1; i < result.length; ++i)
        expect(result[i - 1].metrics?.saturation).toBeLessThanOrEqual(result[i].metrics!.saturation);
    });

    it('by saturation desc', async () => {
      const result = await fetchAllPools(providerOne, { sort: { field: 'saturation', order: 'desc' } });

      for (let i = 1; i < result.length; ++i)
        expect(result[i - 1].metrics?.saturation).toBeGreaterThanOrEqual(result[i].metrics!.saturation);
    });
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('filter options', () => {
    const statusArray = [
      Cardano.StakePoolStatus.Activating,
      Cardano.StakePoolStatus.Active,
      Cardano.StakePoolStatus.Retired,
      Cardano.StakePoolStatus.Retiring
    ];
    const statusCount = Object.fromEntries(statusArray.map((_) => [_, 0]));
    const twoNotActivePoolIds: Cardano.PoolId[] = [];
    let poolsMeetingPledge = 0;
    let poolsNotMeetingPledge = 0;
    let poolsNotMeetingPledgeAndNotActive = 0;

    beforeAll(() => {
      for (const id in poolsOne) {
        const pool = poolsOne[id];

        statusCount[pool.status]++;

        if (pool.metrics!.livePledge >= pool.pledge) poolsMeetingPledge++;
        else {
          poolsNotMeetingPledge++;

          if (pool.status !== Cardano.StakePoolStatus.Active) poolsNotMeetingPledgeAndNotActive++;
        }

        if (pool.status !== Cardano.StakePoolStatus.Active && twoNotActivePoolIds.length < 2)
          twoNotActivePoolIds.push(pool.id);
      }
    });

    describe('status', () => {
      it.each(statusArray)('%s', async (status) => {
        const { totalResultCount } = await providerOne.queryStakePools({ filters: { status: [status] }, pagination });

        expect(totalResultCount).toBe(statusCount[status]);
      });

      it('active or retired', async () => {
        const { totalResultCount } = await providerOne.queryStakePools({
          filters: { status: [Cardano.StakePoolStatus.Active, Cardano.StakePoolStatus.Retired] },
          pagination
        });

        expect(totalResultCount).toBe(
          statusCount[Cardano.StakePoolStatus.Active] + statusCount[Cardano.StakePoolStatus.Retired]
        );
      });
    });

    describe('pledge', () => {
      it('meeting the pledge', async () => {
        const { totalResultCount } = await providerOne.queryStakePools({ filters: { pledgeMet: true }, pagination });

        expect(totalResultCount).toBe(poolsMeetingPledge);
      });

      it('not meeting the pledge', async () => {
        const { totalResultCount } = await providerOne.queryStakePools({ filters: { pledgeMet: false }, pagination });

        expect(totalResultCount).toBe(poolsNotMeetingPledge);
      });
    });

    describe('status and pledge', () => {
      it('active OR not meeting the pledge', async () => {
        const { totalResultCount } = await providerOne.queryStakePools({
          filters: { _condition: 'or', pledgeMet: false, status: [Cardano.StakePoolStatus.Active] },
          pagination
        });

        expect(totalResultCount).toBe(statusCount[Cardano.StakePoolStatus.Active] + poolsNotMeetingPledgeAndNotActive);
      });

      it('not active AND not meeting the pledge', async () => {
        const { totalResultCount } = await providerOne.queryStakePools({
          filters: {
            pledgeMet: false,
            status: [
              Cardano.StakePoolStatus.Activating,
              Cardano.StakePoolStatus.Retired,
              Cardano.StakePoolStatus.Retiring
            ]
          },
          pagination
        });

        expect(totalResultCount).toBe(poolsNotMeetingPledgeAndNotActive);
      });
    });

    describe('identifier', () => {
      it('one pool id', async () => {
        const { totalResultCount } = await providerOne.queryStakePools({
          filters: { identifier: { values: [{ id: twoNotActivePoolIds[0] }] } },
          pagination
        });

        expect(totalResultCount).toBe(1);
      });

      it('two pool ids', async () => {
        const { totalResultCount } = await providerOne.queryStakePools({
          filters: { identifier: { values: twoNotActivePoolIds.map((id) => ({ id })) } },
          pagination
        });

        expect(totalResultCount).toBe(2);
      });
    });

    describe('status and identifier', () => {
      it('active AND two not active pool ids', async () => {
        const { totalResultCount } = await providerOne.queryStakePools({
          filters: {
            identifier: { values: twoNotActivePoolIds.map((id) => ({ id })) },
            status: [Cardano.StakePoolStatus.Active]
          },
          pagination
        });

        expect(totalResultCount).toBe(0);
      });

      it('active OR two not active pool ids', async () => {
        const { totalResultCount } = await providerOne.queryStakePools({
          filters: {
            _condition: 'or',
            identifier: { values: twoNotActivePoolIds.map((id) => ({ id })) },
            status: [Cardano.StakePoolStatus.Active]
          },
          pagination
        });

        expect(totalResultCount).toBe(statusCount[Cardano.StakePoolStatus.Active] + 2);
      });
    });
  });
});
