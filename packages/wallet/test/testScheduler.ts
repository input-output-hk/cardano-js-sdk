import { TestScheduler } from 'rxjs/testing';

export const createTestScheduler = () =>
  new TestScheduler((actual, expected) => {
    expect(actual).toEqual(expected);
  });
