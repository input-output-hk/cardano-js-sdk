import { TrackerSubject } from '../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { lastValueFrom, of } from 'rxjs';

const testUnsubscribeOnCloseAction = (action: (subject: TrackerSubject<string>) => void) => {
  createTestScheduler().run(({ cold, expectSubscriptions }) => {
    const source$ = cold('-----------------a-');
    const subject$ = new TrackerSubject(source$);
    action(subject$);
    expectSubscriptions(source$.subscriptions).toBe('(^!)');
  });
};

describe('TrackerSubject', () => {
  it('does not throw if source immediatelly completes', async () => {
    const subject$ = new TrackerSubject(of(true));
    await lastValueFrom(subject$);
    expect(subject$.value).toBe(true);
  });

  it('value is TrackerSubject.NO_VALUE by default', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const source$ = cold('|');
      const subject$ = new TrackerSubject(source$);
      expectObservable(subject$).toBe('|');
      flush();
      expect(subject$.value).toBe(TrackerSubject.NO_VALUE);
    });
  });

  it('mirrors source and updates value', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const source$ = cold('-a-b-c-|');
      const subject$ = new TrackerSubject(source$);
      expectObservable(subject$).toBe('-a-b-c-|');
      flush();
      expect(subject$.value).toBe('c');
    });
  });

  it('unsubscribes from source on complete(), error() or unsubscribe()', () => {
    testUnsubscribeOnCloseAction((tracker) => {
      tracker.complete();
    });
    testUnsubscribeOnCloseAction((tracker) => tracker.error(new Error('any error')));
    testUnsubscribeOnCloseAction((tracker) => tracker.unsubscribe());
  });
});
