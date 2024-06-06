import { concat } from 'rxjs';
import { createStubObservable, createTestScheduler } from '../src/index.js';

describe('createStubObservable', () => {
  it('returns an observable that subscribes to observables provided as arguments in order', () => {
    createTestScheduler().run(({ cold, expectObservable, expectSubscriptions }) => {
      const a$ = cold('a|');
      const b$ = cold('b|');
      const target$ = createStubObservable(a$, b$);
      expectObservable(concat(target$, target$)).toBe('ab|');
      expectSubscriptions(a$.subscriptions).toBe('^!');
      expectSubscriptions(b$.subscriptions).toBe('-^!');
    });
  });
});
