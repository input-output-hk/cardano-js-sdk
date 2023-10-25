import { OperatorFunction, of } from 'rxjs';
import { STAKE_POOL_METRICS_UPDATE, createStorePoolMetricsUpdateJob } from '../../src';

const testPromise = () => {
  let resolvePromise: Function;
  const promise = new Promise<void>((resolve) => (resolvePromise = resolve));
  return [promise, resolvePromise!] as const;
};

const createEvent = (send: jest.Mock<Promise<void>, []>, blockNo: number, tipSlot?: number) => ({
  block: { header: { blockNo, slot: blockNo * 10 } },
  eventType: 0,
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
      createEvent(send, 10), // generates a std event
      createEvent(send, 11),
      createEvent(send, 10), // doesn't generate event due to rollback
      createEvent(send, 11),
      createEvent(send, 12),
      createEvent(send, 13),
      createEvent(send, 14),
      createEvent(send, 15), // generates a std event
      createEvent(send, 16)
    )
      .pipe(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        createStorePoolMetricsUpdateJob(5)() as OperatorFunction<any, any>
      )
      .subscribe();

    await promise;

    expect(send).toBeCalledTimes(3);
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 80 }, { slot: 80 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 100 }, { slot: 100 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 150 }, { slot: 150 });
  });

  it('sends jobs only at expected blocks for outdated job', async () => {
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
      createEvent(send, 9), // generates a outdated event
      createEvent(send, 10), // generates a std event
      createEvent(send, 11),
      createEvent(send, 10), // doesn't generate event due to rollback
      createEvent(send, 11),
      createEvent(send, 12), // generates a outdated event
      createEvent(send, 13),
      createEvent(send, 14),
      createEvent(send, 15), // generates a std event, doesn't generate outdated event
      createEvent(send, 16)
    )
      .pipe(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        createStorePoolMetricsUpdateJob(5, 3)() as OperatorFunction<any, any>
      )
      .subscribe();

    await promise;

    expect(send).toBeCalledTimes(5);
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 80 }, { slot: 80 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { outdatedSlot: 80, slot: 90 }, { slot: 90 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 100 }, { slot: 100 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { outdatedSlot: 100, slot: 120 }, { slot: 120 });
    expect(send).toBeCalledWith(STAKE_POOL_METRICS_UPDATE, { slot: 150 }, { slot: 150 });
  });
});
