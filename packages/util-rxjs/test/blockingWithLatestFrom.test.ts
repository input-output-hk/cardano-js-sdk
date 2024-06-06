/* eslint-disable no-multi-spaces */

import { blockingWithLatestFrom } from '../src/index.js';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { delay, firstValueFrom, from, of, toArray } from 'rxjs';

/* eslint-disable prettier/prettier */
describe('blockingWithLatestFrom', () => {
  it(`waits for dependency$ to emit,
      does not lose any source emissions,
      subscribes only once,
      unsubscribes from dependency$ when source completes`, () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ =     hot('abc----de|');
      const dependency$ = hot('--a---b--');
      expectObservable(source$.pipe(blockingWithLatestFrom(dependency$))).toBe('--(abc)de|', {
        a: ['a', 'a'],
        b: ['b', 'a'],
        c: ['c', 'a'],
        d: ['d', 'b'],
        e: ['e', 'b']
      });
      expectSubscriptions(source$.subscriptions).toBe('^--------!');
      expectSubscriptions(dependency$.subscriptions).toBe('^--------!');
    });
  });

  it('works correctly when dependency emits instantly on subscription', async () => {
    const source$ =     from(['a', 'b']).pipe(delay(1));
    const dependency$ = of('a');
    const result = await firstValueFrom(source$.pipe(blockingWithLatestFrom(dependency$), toArray()));
    expect(result).toEqual([['a', 'a'], ['b', 'a']]);
  });

  it('works correctly when both source and dependency emit 1st item instantly on subscription', () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const source$ =     hot('abc');
      const dependency$ = hot('a');
      expectObservable(source$.pipe(blockingWithLatestFrom(dependency$))).toBe('abc', {
        a: ['a', 'a'],
        b: ['b', 'a'],
        c: ['c', 'a']
      });
    });
  });

  it('accepts a 2nd argument to map the values', async () => {
    const source$ =     of('a');
    const dependency$ = of('b');
    const result = await firstValueFrom(source$.pipe(blockingWithLatestFrom(dependency$, (a, b) => a + b), toArray()));
    expect(result).toEqual(['ab']);
  });
});
