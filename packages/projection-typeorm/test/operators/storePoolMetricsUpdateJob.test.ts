import { OperatorFunction, of } from 'rxjs';
import { STAKE_POOL_METRICS_UPDATE, createStorePoolMetricsUpdateJob } from '../../src';

const testPromise = () => {
  let resolvePromise: Function;
  const promise = new Promise<void>((resolve) => (resolvePromise = resolve));
  return [promise, resolvePromise!] as const;
};

describe('createStorePoolMetricsUpdateJob', () => {
  it('sends jobs only at expected blocks', async () => {
    let counter = 0;
    const [promise, resolver] = testPromise();
    const send = jest.fn(() => {
      if (++counter === 3) resolver();
      return Promise.resolve();
    });
    const createEvent = (blockNo: number, tipSlot?: number) => ({
      block: { header: { blockNo, slot: blockNo * 10 } },
      eventType: 0,
      pgBoss: { send },
      tip: { slot: tipSlot ?? blockNo * 10 }
    });

    of(
      createEvent(2, 80),
      createEvent(3, 80),
      createEvent(4, 80),
      createEvent(5, 80), // doesn't generate event since tip is not reached
      createEvent(6, 80),
      createEvent(7, 80),
      createEvent(8), // generates first event once tip is reached
      createEvent(9),
      createEvent(10), // generates a std event
      createEvent(11),
      createEvent(10), // doesn't generate event due to rollback
      createEvent(11),
      createEvent(12),
      createEvent(13),
      createEvent(14),
      createEvent(15), // generates a std event
      createEvent(16)
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
});
