/* eslint-disable prettier/prettier */
/* eslint-disable space-in-parens */
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { oneDistinctAfterTrigger, strictEquals } from '../../../src';

describe('oneDistinctAfterTrigger', () => {
  // eslint-disable-next-line max-len
  it('mirrors source observable, but delays 1 emission after each `trigger$` until source emits an updated value', () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const trigger$ = hot('a-a---a--a');
      const source$ = hot( 'a-aabc-d-e');
      const target$ = source$.pipe(oneDistinctAfterTrigger(trigger$, strictEquals));

      expectObservable(target$).toBe('a---bc-d-e');
    });
  });
});
