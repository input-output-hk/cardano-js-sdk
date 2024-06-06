import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { STAKE_POOL_REWARDS, storeStakePoolRewardsJob, willStoreStakePoolRewardsJob } from '../../src/index.js';
import { of } from 'rxjs';
import type { OperatorFunction } from 'rxjs';

const testPromise = () => {
  let resolvePromise: Function;
  const promise = new Promise<void>((resolve) => (resolvePromise = resolve));
  return [promise, resolvePromise!] as const;
};

describe('storeStakePoolRewardsJob', () => {
  it('sends jobs at epoch rollover', async () => {
    let counter = 0;
    const [promise, resolver] = testPromise();
    const send = jest.fn(() => {
      if (++counter === 3) resolver();
      return Promise.resolve();
    });
    const createEvent = (blockNo: number, crossEpochBoundary: boolean, eventType = ChainSyncEventType.RollForward) => ({
      block: { header: { blockNo, slot: blockNo * 10 } },
      crossEpochBoundary,
      epochNo: Math.ceil(blockNo / 100),
      eventType,
      pgBoss: { send }
    });

    of(
      createEvent(50, false),
      createEvent(100, false),
      createEvent(101, true),
      createEvent(99, false, ChainSyncEventType.RollBackward),
      createEvent(103, true),
      createEvent(199, false),
      createEvent(200, false),
      createEvent(201, true),
      createEvent(202, false),
      createEvent(203, false)
    )
      .pipe(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        storeStakePoolRewardsJob() as OperatorFunction<any, any>
      )
      .subscribe();

    await promise;

    expect(send).toBeCalledTimes(3);
    expect(send).toBeCalledWith(
      STAKE_POOL_REWARDS,
      { epochNo: 0 },
      { expireInHours: 6, retentionDays: 365, retryDelay: 30, retryLimit: 1_000_000, singletonKey: '0', slot: 1010 }
    );
    expect(send).toBeCalledWith(
      STAKE_POOL_REWARDS,
      { epochNo: 0 },
      { expireInHours: 6, retentionDays: 365, retryDelay: 30, retryLimit: 1_000_000, singletonKey: '0', slot: 1030 }
    );
    expect(send).toBeCalledWith(
      STAKE_POOL_REWARDS,
      { epochNo: 1 },
      { expireInHours: 6, retentionDays: 365, retryDelay: 30, retryLimit: 1_000_000, singletonKey: '1', slot: 2010 }
    );
  });
});

describe('willStoreStakePoolRewardsJob', () => {
  it('returns true if is at epoch boundary and epoch is greater than 1', () => {
    expect(
      willStoreStakePoolRewardsJob({
        crossEpochBoundary: true,
        epochNo: Cardano.EpochNo(2)
      })
    ).toBeTruthy();
  });
  it('returns false if not at epoch boundary', () => {
    expect(
      willStoreStakePoolRewardsJob({
        crossEpochBoundary: false,
        epochNo: Cardano.EpochNo(2)
      })
    ).toBeFalsy();
  });
  it('returns false if at first epoch', () => {
    expect(
      willStoreStakePoolRewardsJob({
        crossEpochBoundary: true,
        epochNo: Cardano.EpochNo(1)
      })
    ).toBeFalsy();
  });
});
