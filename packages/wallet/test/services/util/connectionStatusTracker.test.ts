import { ConnectionStatus, createSimpleConnectionStatusTracker } from '../../../src/index.js';
import { Subject, filter, firstValueFrom } from 'rxjs';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import type { ConnectionStatusTrackerInternals } from '../../../src/index.js';

describe('createSimpleConnectionStatusTracker', () => {
  it('creates ConnectionStatusTracker that always emits `up` when in Node', async () => {
    createTestScheduler().run(({ expectObservable }) => {
      const nodeConnection$ = createSimpleConnectionStatusTracker({ isNodeEnv: true });
      expectObservable(nodeConnection$).toBe('p', { p: ConnectionStatus.up });
    });
  });

  describe('Browser', () => {
    let mockInternals: ConnectionStatusTrackerInternals;
    const connEvents = new Subject<boolean>();

    beforeEach(() => {
      mockInternals = {
        initialStatus: true,
        isNodeEnv: false,
        offline$: connEvents.pipe(filter((online) => !online)),
        online$: connEvents.pipe(filter((online) => online))
      };
    });

    it('emits initialStatus as starting value', async () => {
      const connectionStatus = firstValueFrom(createSimpleConnectionStatusTracker(mockInternals));
      expect(await connectionStatus).toBe(ConnectionStatus.up);
    });

    it('emits `down` when offline$ emits', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        mockInternals.offline$ = cold('-a|');
        mockInternals.online$ = cold('--|');
        const connectionStatus$ = createSimpleConnectionStatusTracker(mockInternals);
        expectObservable(connectionStatus$).toBe('xd|', { d: ConnectionStatus.down, x: ConnectionStatus.up });
      });
    });

    it('emits only distinct values', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        mockInternals.offline$ = cold('-aa|');
        mockInternals.online$ = cold('---|');
        const connectionStatus$ = createSimpleConnectionStatusTracker(mockInternals);
        expectObservable(connectionStatus$).toBe('xd-|', { d: ConnectionStatus.down, x: ConnectionStatus.up });
      });
    });

    it('subsequent subscribers get the last known value', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        mockInternals.offline$ = cold('---|');
        mockInternals.online$ = cold('---|');

        const connectionStatus$ = createSimpleConnectionStatusTracker(mockInternals);
        expectObservable(connectionStatus$).toBe('u--|', { u: ConnectionStatus.up });
        expectObservable(connectionStatus$).toBe('u--|', { u: ConnectionStatus.up });
      });
    });
  });
});
