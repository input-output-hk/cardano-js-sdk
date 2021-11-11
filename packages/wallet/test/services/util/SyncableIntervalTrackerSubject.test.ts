import { Milliseconds } from '../../../src';
import { Observable, interval, take } from 'rxjs';
import { SyncableIntervalTrackerSubject } from '../../../src/services/util';
import { createTestScheduler } from '../../testScheduler';

const testInterval = ({ pollInterval, numTriggers }: { pollInterval: number; numTriggers: number }) =>
  interval(pollInterval).pipe(take(numTriggers));

const stubObservableProvider = <T>(...calls: Observable<T>[]) => {
  let numCall = 0;
  return new Observable<T>((subscriber) => {
    const sub = calls[numCall++].subscribe(subscriber);
    return () => sub.unsubscribe();
  });
};

describe('ProviderTrackerSubject', () => {
  let pollInterval: Milliseconds; // not used, overwriting interval$

  it('calls the provider immediately and then every [pollInterval], only emitting distinct values', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const provider$ = stubObservableProvider(cold('--a|'), cold('--b|'), cold('c|'));
      const tracker$ = new SyncableIntervalTrackerSubject(
        { pollInterval, provider$ },
        { interval$: testInterval({ numTriggers: 2, pollInterval: 5 }) }
      );
      expectObservable(tracker$.asObservable()).toBe('--a----b--c');
    });
  });

  it('doesnt wait for subscriptions to subscribe to underlying provider', () => {
    createTestScheduler().run(({ cold, flush }) => {
      const provider$ = cold('--a|');
      const tracker$ = new SyncableIntervalTrackerSubject(
        { pollInterval, provider$ },
        { interval$: testInterval({ numTriggers: 3, pollInterval: 5 }) }
      );
      flush();
      expect(tracker$.value).toBe('a');
    });
  });

  it('throttles interval requests to provider', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const provider$ = stubObservableProvider(cold('-----a|'), cold('-----b|'), cold('c'));
      const tracker$ = new SyncableIntervalTrackerSubject(
        { pollInterval, provider$ },
        { interval$: testInterval({ numTriggers: 3, pollInterval: 5 }) }
      );
      expectObservable(tracker$).toBe('-----a---------b');
    });
  });

  // The code is fairly simple, but quite a few additional tests are needed to test all paths
  it.todo('external trigger cancels an ongoing interval request and makes a new one');
  it.todo('external trigger cancels an ongoing external trigger request and makes a new one');
  it.todo('sync() calls external trigger');
  it.todo('retries on interval requests failure with exponential backoff strategy');
  it.todo('retries on any external trigger requests failure with exponential backoff strategy');
});
