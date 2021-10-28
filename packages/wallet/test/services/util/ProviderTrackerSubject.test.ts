import { ProviderTrackerSubject } from '../../../src/services/util';
import { createTestScheduler } from '../../testScheduler';
import { interval, take } from 'rxjs';

const trigger = ({ pollInterval, numTriggers }: { pollInterval: number; numTriggers: number }) =>
  interval(pollInterval).pipe(take(numTriggers));

describe('ProviderTrackerSubject', () => {
  const config = { maxInterval: 25, pollInterval: 5 };

  it('calls the provider immediately and then every [pollInterval]', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const provider = jest.fn().mockReturnValue(cold('--a|'));
      const tracker$ = new ProviderTrackerSubject(
        { config, provider },
        { trigger$: trigger({ numTriggers: 3, pollInterval: 5 }) }
      );
      expectObservable(tracker$.asObservable()).toBe('--a----a----a----a');
      flush();
      expect(provider).toBeCalledTimes(4);
    });
  });

  it('doesnt wait for subscriptions to subscribe to underlying provider', () => {
    createTestScheduler().run(({ cold, flush }) => {
      const provider = jest.fn().mockReturnValue(cold('--a|'));
      const tracker$ = new ProviderTrackerSubject(
        { config, provider },
        { trigger$: trigger({ numTriggers: 3, pollInterval: 5 }) }
      );
      flush();
      expect(provider).toBeCalledTimes(4);
      expect(tracker$.value).toBe('a');
    });
  });

  it('throttles interval requests to provider', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const provider = jest.fn().mockReturnValue(cold('-----a|'));
      const tracker$ = new ProviderTrackerSubject(
        { config, provider },
        { trigger$: trigger({ numTriggers: 3, pollInterval: 5 }) }
      );
      expectObservable(tracker$).toBe('-----a---------a');
      flush();
      expect(provider).toBeCalledTimes(2);
    });
  });

  it.todo('external trigger cancels an ongoing interval request and makes a new one');
  it.todo('external trigger cancels an ongoing external trigger request and makes a new one');
  it.todo('sync() calls external trigger');
  it.todo('retries on interval requests failure with exponential backoff strategy');
  it.todo('retries on any external trigger requests failure with exponential backoff strategy');
});
