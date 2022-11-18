/* eslint-disable no-multi-spaces */

import { blockingWithLatestFrom } from '../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { firstValueFrom, from, of, toArray } from 'rxjs';

/* eslint-disable prettier/prettier */
describe('blockingWithLatestFrom', () => {
  it('waits for dependency$ to emit, does not lose any source emissions and subscribes only once', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ =     hot('ab-----c-d');
      const dependency$ = hot('--a---b---');
      expectObservable(source$.pipe(blockingWithLatestFrom(dependency$))).toBe('---(ab)c-d', {
        a: ['a', 'a'],
        b: ['b', 'a'],
        c: ['c', 'b'],
        d: ['d', 'b']
      });
      expectSubscriptions(source$.subscriptions).toBe('^');
      expectSubscriptions(dependency$.subscriptions).toBe('^');
    });
  });

  it('works correctly when dependency emits instantly on subscription', async () => {
    const source$ =     from(['a', 'b']);
    const dependency$ = of('a');
    const result = await firstValueFrom(source$.pipe(blockingWithLatestFrom(dependency$), toArray()));
    expect(result).toEqual([['a', 'a'], ['b', 'a']]);
  });

  it('accepts a 2nd argument to map the values', async () => {
    const source$ =     of('a');
    const dependency$ = of('b');
    const result = await firstValueFrom(source$.pipe(blockingWithLatestFrom(dependency$, (a, b) => a + b), toArray()));
    expect(result).toEqual(['ab']);
  });
});
