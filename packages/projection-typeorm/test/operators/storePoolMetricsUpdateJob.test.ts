import { ChainSyncEventType } from '@cardano-sdk/core';
import { OperatorFunction, of } from 'rxjs';
import { STAKE_POOL_METRICS_UPDATE, createStorePoolMetricsUpdateJob } from '../../src';

const testPromise = () => {
  let resolvePromise: Function;
  const promise = new Promise<void>((resolve) => (resolvePromise = resolve));
  return [promise, resolvePromise!] as const;
};

const createEvent = (send: jest.Mock<Promise<void>, []>, blockNo: number, tipSlot?: number) => ({
  block: { header: { blockNo, slot: blockNo * 10 } },
  eventType: ChainSyncEventType.RollForward,
  pgBoss: { send },
  tip: { slot: tipSlot ?? blockNo * 10 }
});

describe('createStorePoolMetricsUpdateJob', () => {
  it('sends jobs only at expected blocks', async () => {
    let counter = 0;
    const [promise, resolver] = testPromise();
    const send = jest.fn(() => {
      if (++counter === 3) resolver();
      return Promise.resolve();
    });

    of(
      createEvent(send, 2, 80),
      createEvent(send, 3, 80),
      createEvent(send, 4, 80),
      createEvent(send, 5, 80), // doesn't generate event since tip is not reached
      createEvent(send, 6, 80),
      createEvent(send, 7, 80),
      createEvent(send, 8), // generates first event once tip is reached
      createEvent(send, 9),
      createEvent(send, 10),
      createEvent(send, 11),
      createEvent(send, 10), // doesn't generate event due to rollback
      createEvent(send, 11),
      createEvent(send, 12),
      createEvent(send, 13), // generates a std event
      createEvent(send, 14),
      createEvent(send, 15),
      createEvent(send, 16),
      createEvent(send, 17),
      createEvent(send, 18) // generates a std event
    )
      .pipe(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        createStorePoolMetricsUpdateJob(5)() as OperatorFunction<any, any>
      )
      .subscribe();

    await promise;

    expect(send).toBeCalledTimes(3);
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 80 }, { slot: 80 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 130 }, { slot: 130 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 180 }, { slot: 180 });
  });

  it('sends jobs only at expected blocks for outdated job', async () => {
    let counter = 0;
    const [promise, resolver] = testPromise();
    const send = jest.fn(() => {
      if (++counter === 6) resolver();
      return Promise.resolve();
    });

    of(
      createEvent(send, 2, 80),
      createEvent(send, 3, 80), // doesn't generate event since tip is not reached & outdatedSlot is undefined yet
      createEvent(send, 4, 80),
      createEvent(send, 5, 80), // doesn't generate event since tip is not reached
      createEvent(send, 6, 80), // doesn't generate event since tip is not reached & outdatedSlot is undefined yet
      createEvent(send, 7, 80),
      createEvent(send, 8), // generates first event once tip is reached
      createEvent(send, 9),
      createEvent(send, 10),
      createEvent(send, 11), // generates a outdated event (3 blocks since first update)
      createEvent(send, 10),
      createEvent(send, 11), // doesn't generate event due to rollback
      createEvent(send, 12),
      createEvent(send, 13), // generates a std event (5 blocks since first update)
      createEvent(send, 14), // generates outdated event (6 blocks since first update)
      createEvent(send, 15),
      createEvent(send, 16),
      createEvent(send, 17), // generates outdated event (9 blocks since first update)
      createEvent(send, 18), // generates a std event (10 blocks since first update)
      createEvent(send, 19)
    )
      .pipe(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        createStorePoolMetricsUpdateJob(5, 3)() as OperatorFunction<any, any>
      )
      .subscribe();

    await promise;

    expect(send).toBeCalledTimes(6);
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 80 }, { slot: 80 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { outdatedSlot: 80, slot: 110 }, { slot: 110 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 130 }, { slot: 130 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { outdatedSlot: 130, slot: 140 }, { slot: 140 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { outdatedSlot: 130, slot: 170 }, { slot: 170 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 180 }, { slot: 180 });
  });

  it('sends jobs even if events have gaps on blocks', async () => {
    let counter = 0;
    const [promise, resolver] = testPromise();
    const send = jest.fn(() => {
      if (++counter === 5) resolver();
      return Promise.resolve();
    });

    of(
      createEvent(send, 2, 80),
      createEvent(send, 3, 80), // doesn't generate event since tip is not reached & outdatedSlot is undefined yet
      createEvent(send, 4, 80),
      createEvent(send, 5, 80), // doesn't generate event since tip is not reached
      createEvent(send, 6, 80), // doesn't generate event since tip is not reached & outdatedSlot is undefined yet
      createEvent(send, 7, 80),
      createEvent(send, 8), // generates first event once tip is reached
      createEvent(send, 11), // generates a outdated event
      createEvent(send, 1008), // generates a std event
      createEvent(send, 1012), // generates outdated event
      createEvent(send, 2000) // generates a std event
    )
      .pipe(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        createStorePoolMetricsUpdateJob(5, 3)() as OperatorFunction<any, any>
      )
      .subscribe();

    await promise;

    expect(send).toBeCalledTimes(5);
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 80 }, { slot: 80 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { outdatedSlot: 80, slot: 110 }, { slot: 110 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 10_080 }, { slot: 10_080 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { outdatedSlot: 10_080, slot: 10_120 }, { slot: 10_120 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 20_000 }, { slot: 20_000 });
  });
});
