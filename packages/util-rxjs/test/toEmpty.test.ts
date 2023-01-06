import { createTestScheduler } from '@cardano-sdk/util-dev';
import { toEmpty } from '../src';

describe('toEmpty', () => {
  it('supresses emissions', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot('a-b');
      expectObservable(source$.pipe(toEmpty)).toBe('----');
      expectSubscriptions(source$.subscriptions).toBe('^');
    });
  });
});
