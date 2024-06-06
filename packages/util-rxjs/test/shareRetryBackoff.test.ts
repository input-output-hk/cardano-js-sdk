import { createTestScheduler } from '@cardano-sdk/util-dev';
import { map } from 'rxjs';
import { shareRetryBackoff } from '../src/index.js';
import type { OperatorFunction } from 'rxjs';

const passthrough = <T>(a: T) => a;
const throwError = <T>(_: T) => {
  throw new Error('any error');
};

describe('shareRetryBackoff', () => {
  it('Subscribes to source observable once and wraps `operator` with retry logic', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions, flush }) => {
      const source$ = hot('a-b');
      // 'a' goes through the operator successfully
      // For 'b', operator throws twice before succeeding
      const mapSourceItem = jest
        .fn<string, [string]>()
        .mockImplementationOnce(passthrough)
        .mockImplementationOnce(throwError)
        .mockImplementationOnce(throwError)
        .mockImplementationOnce(passthrough);

      const operator: OperatorFunction<string, string> = jest
        .fn()
        .mockImplementation((evt$) => evt$.pipe(map(mapSourceItem)));

      // 10ms delay + 20ms delay
      expectObservable(source$.pipe(shareRetryBackoff(operator)), '^ 32ms !').toBe('a 31ms b');
      // source$ is subscribed exactly once, and unsubscribed when the observable is unsubscribed externally
      expectSubscriptions(source$.subscriptions).toBe('^ 32ms !');

      flush();
      // passthrough + error + error
      expect(operator).toBeCalledTimes(3);
      expect(mapSourceItem).toBeCalledTimes(4);
    });
  });
});
