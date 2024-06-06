import { Milliseconds } from '@cardano-sdk/core';
import { Observable } from 'rxjs';
import { ProjectionHttpService, ProjectionName } from '../../src/index.js';
import { dummyLogger } from 'ts-log';
import delay from 'delay';
import type { BaseProjectionEvent } from '@cardano-sdk/projection';
import type { Cardano, HealthCheckResponse } from '@cardano-sdk/core';

describe('ProjectionHttpService', () => {
  const healthTimeout = Milliseconds(10);
  let projection$: Observable<BaseProjectionEvent>;
  let unsubscribe: jest.Mock;
  let subscriptionCallback: (evt: {
    tip: {
      blockNo: number;
      hash?: string;
    };
    block: {
      header: {
        blockNo: number;
        hash?: string;
      };
    };
  }) => void;
  let service: ProjectionHttpService<BaseProjectionEvent>;

  beforeEach(async () => {
    unsubscribe = jest.fn();
    projection$ = new Observable<BaseProjectionEvent>((observer) => {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      subscriptionCallback = (evt: any) => observer.next(evt);
      return unsubscribe;
    });
    jest.spyOn(projection$, 'subscribe');
    service = new ProjectionHttpService(
      {
        healthTimeout,
        projection$,
        projectionNames: [ProjectionName.UTXO]
      },
      { logger: dummyLogger }
    );
    await service.initialize();
  });

  afterEach(async () => service.state === 'running' && (await service.shutdown()));

  it('subscribes to projection$ on start() and unsubscribes on shutdown()', async () => {
    expect(projection$.subscribe).not.toBeCalled();
    await service.start();
    expect(projection$.subscribe).toBeCalledTimes(1);
    expect(unsubscribe).not.toBeCalled();
    await service.shutdown();
    expect(unsubscribe).toBeCalledTimes(1);
  });

  describe('healthCheck', () => {
    it('is unhealthy before starting', async () => expect(await service.healthCheck()).toMatchObject({ ok: false }));

    it('is unhealthy after starting, before emitting any event', async () => {
      await service.start();
      expect(await service.healthCheck()).toMatchObject({ ok: false });
    });

    it('is unhealthy after starting, when current projected tip is not equal to local node tip', async () => {
      await service.start();
      const evt = { block: { header: { blockNo: 1 } }, tip: { blockNo: 2 } };
      subscriptionCallback(evt);
      expect(await service.healthCheck()).toMatchObject({
        localNode: { ledgerTip: evt.tip },
        ok: false,
        projectedTip: { blockNo: evt.block.header.blockNo } as Cardano.PartialBlockHeader
      } as HealthCheckResponse);
    });

    it('is healthy after starting, when current projected tip is equal to local node tip', async () => {
      await service.start();
      const evt = { block: { header: { blockNo: 2 } }, tip: { blockNo: 2 } };
      subscriptionCallback(evt);
      expect(await service.healthCheck()).toMatchObject({
        localNode: { ledgerTip: evt.tip },
        ok: true,
        projectedTip: { blockNo: evt.block.header.blockNo } as Cardano.PartialBlockHeader
      } as HealthCheckResponse);
    });

    it('is unhealthy after starting, when no events are projected within "healthTimeout", then healthy when it recovers', async () => {
      await service.start();
      const evt = { block: { header: { blockNo: 2 } }, tip: { blockNo: 2 } };
      subscriptionCallback(evt);
      expect((await service.healthCheck()).ok).toBe(true);
      await delay(healthTimeout + 1);
      expect((await service.healthCheck()).ok).toBe(false);
      subscriptionCallback(evt);
      expect((await service.healthCheck()).ok).toBe(true);
    });
  });
});
