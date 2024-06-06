import { concatAndCombineLatest } from '../src/index.js';
import { createTestScheduler } from '@cardano-sdk/util-dev';

describe('concatAndCombineLatest', () => {
  it('emits an empty array if the source is an empty array', () => {
    createTestScheduler().run(({ expectObservable }) => {
      expectObservable(concatAndCombineLatest([])).toBe('(a|)', { a: [] });
    });
  });

  it('mirrors the values wrapped in array, given an array with a single observable', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const o$ = cold('xy|');
      expectObservable(concatAndCombineLatest([o$])).toBe('ab|', { a: ['x'], b: ['y'] });
    });
  });

  it('concats the emitted values for two observables', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const o1$ = cold('x|');
      const o2$ = cold('y|');
      expectObservable(concatAndCombineLatest([o1$, o2$])).toBe('a|', { a: ['x', 'y'] });
    });
  });

  it(`for multiple observables,
      subscribes sequentially like concat,
      based on prev emitting at least once, instead of complete event,
      and combines them like combineLatest
      `, () => {
    createTestScheduler().run(({ cold, expectObservable, expectSubscriptions }) => {
      const o1$ = cold('-a--b--c|');
      const o2$ = cold(' ---x-y--z|');
      const o3$ = cold('    -m|');

      expectObservable(concatAndCombineLatest([o1$, o2$, o3$])).toBe('-----abc-d|', {
        a: ['b', 'x', 'm'],
        b: ['b', 'y', 'm'],
        c: ['c', 'y', 'm'],
        d: ['c', 'z', 'm']
      });

      expectSubscriptions(o1$.subscriptions).toBe('^-------!');
      expectSubscriptions(o2$.subscriptions).toBe('-^--------!');
      expectSubscriptions(o3$.subscriptions).toBe('----^-!');
    });
  });
});
