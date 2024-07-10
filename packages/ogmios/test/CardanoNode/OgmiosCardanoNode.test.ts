/* eslint-disable sonarjs/no-duplicate-string */
import {
  Cardano,
  EraSummary,
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  HealthCheckResponse,
  Milliseconds,
  StakeDistribution,
  StateQueryError,
  StateQueryErrorCode
} from '@cardano-sdk/core';
import { InvalidModuleState } from '@cardano-sdk/util';
import { OgmiosCardanoNode, OgmiosObservableCardanoNode } from '../../src';
import { ReplaySubject, Subject } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';

const expectShutdownRejection = async (promise: Promise<unknown>) => {
  await expect(promise).rejects.toThrowError(
    expect.objectContaining({
      code: GeneralCardanoNodeErrorCode.ServerNotReady,
      message: 'OgmiosCardanoNode is shutting down.'
    })
  );
};

const expectTimeoutRejection = async (promise: Promise<unknown>) => {
  await expect(promise).rejects.toThrowError(
    expect.objectContaining({
      code: GeneralCardanoNodeErrorCode.ConnectionFailure,
      message: 'Timeout'
    })
  );
};

describe('OgmiosCardanoNode', () => {
  let node: OgmiosCardanoNode;
  let ogmiosObservableCardanoNode: OgmiosObservableCardanoNode;
  let eraSummaries$: Subject<EraSummary[]>;
  let stakeDistribution$: Subject<StakeDistribution>;
  let healthCheck$: Subject<HealthCheckResponse>;
  let systemStart$: Subject<Date>;

  beforeEach(async () => {
    eraSummaries$ = new ReplaySubject<EraSummary[]>();
    stakeDistribution$ = new ReplaySubject<StakeDistribution>();
    healthCheck$ = new ReplaySubject<HealthCheckResponse>();
    systemStart$ = new ReplaySubject<Date>();

    ogmiosObservableCardanoNode = {
      eraSummaries$,
      healthCheck$,
      stakeDistribution$,
      systemStart$
    } as unknown as OgmiosObservableCardanoNode;
  });

  describe('not initialized and started', () => {
    beforeEach(async () => {
      node = new OgmiosCardanoNode(ogmiosObservableCardanoNode, logger);
    });

    it('eraSummaries rejects with not initialized error', async () => {
      await expect(node.eraSummaries()).rejects.toThrowError(GeneralCardanoNodeError);
    });
    it('systemStart rejects with not initialized error', async () => {
      await expect(node.systemStart()).rejects.toThrowError(GeneralCardanoNodeError);
    });
    it('stakeDistribution rejects with not initialized error', async () => {
      await expect(node.stakeDistribution()).rejects.toThrowError(GeneralCardanoNodeError);
    });
    it('shutdown rejects with not initialized error', async () => {
      await expect(node.shutdown()).rejects.toThrowError(InvalidModuleState);
    });
  });

  describe('initialized and started', () => {
    beforeEach(async () => {
      node = new OgmiosCardanoNode(ogmiosObservableCardanoNode, logger);
      await node.initialize();
      await node.start();
    });

    describe('eraSummaries', () => {
      afterEach(async () => {
        await node.shutdown();
      });

      it('resolves if successful', async () => {
        const eraSummaries = [
          {
            parameters: {
              epochLength: 1,
              slotLength: Milliseconds(1000)
            },
            start: {
              slot: 0,
              time: new Date('2022-08-09T00:00:00.000Z')
            }
          }
        ];
        eraSummaries$.next(eraSummaries);
        const res = await node.eraSummaries();

        expect(res).toEqual(eraSummaries);
      });

      it('rejects with errors thrown by the service', async () => {
        eraSummaries$.error(new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, 'Some error'));
        await expect(node.eraSummaries()).rejects.toThrowError(StateQueryError);
      });
    });

    it('timeout rejects with connection failure error', async () => {
      jest.useFakeTimers();

      const eraSummaries = node.eraSummaries();
      const stakeDistribution = node.stakeDistribution();
      const systemStart = node.systemStart();

      jest.advanceTimersByTime(10_000);

      await expectTimeoutRejection(eraSummaries);
      await expectTimeoutRejection(stakeDistribution);
      await expectTimeoutRejection(systemStart);

      jest.useRealTimers();
    });

    it('shutting down cancels the observable and rejects with ServerNotReady error', async () => {
      const eraSummaries = node.eraSummaries();
      const stakeDistribution = node.stakeDistribution();
      const systemStart = node.systemStart();

      await node.shutdown();

      await expectShutdownRejection(eraSummaries);
      await expectShutdownRejection(stakeDistribution);
      await expectShutdownRejection(systemStart);
    });

    describe('systemStart', () => {
      const startTime = new Date();

      afterEach(async () => {
        await node.shutdown();
      });

      it('resolves if successful', async () => {
        systemStart$.next(startTime);
        const res = await node.systemStart();
        expect(res).toEqual(startTime);
      });

      it('rejects with errors thrown by the service', async () => {
        systemStart$.error(new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, 'Some error'));
        await expect(node.systemStart()).rejects.toThrowError(StateQueryError);
      });
    });

    describe('healthCheck', () => {
      it('returns ok if successful', async () => {
        healthCheck$.next({ ok: true });
        const res = await node.healthCheck();
        expect(res.ok).toBe(true);
      });

      it('returns not ok when shutting down', async () => {
        const healthCheck = node.healthCheck();
        await node.shutdown();
        await expect(healthCheck).resolves.toEqual({ message: 'OgmiosCardanoNode is shutting down.', ok: false });
      });
    });

    describe('stakeDistribution', () => {
      afterEach(async () => {
        await node.shutdown();
      });

      it('resolves if successful', async () => {
        const stakeDistribution: StakeDistribution = new Map();
        stakeDistribution.set(Cardano.PoolId('pool1cjm567pd9eqj7wlpuq2mnsasw2upewq0tchg4n8gktq5k7eepvr'), {
          stake: { pool: BigInt(1), supply: BigInt(100) },
          vrf: 'vrf' as Cardano.VrfVkHex
        });

        stakeDistribution$.next(stakeDistribution);
        const res = await node.stakeDistribution();
        expect(res).toEqual(stakeDistribution);
      });

      it('rejects with errors thrown by the service', async () => {
        stakeDistribution$.error(new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, 'Some error'));
        await expect(node.stakeDistribution()).rejects.toThrowError(StateQueryError);
      });
    });

    describe('shutdown', () => {
      it('shuts down successfully', async () => {
        await expect(node.shutdown()).resolves.not.toThrow();
      });

      it('throws when querying after shutting down', async () => {
        await node.shutdown();
        await expect(node.systemStart()).rejects.toThrowError(GeneralCardanoNodeError);
      });
    });
  });
});
