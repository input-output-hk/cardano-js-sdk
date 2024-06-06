import type { Observable } from 'rxjs';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const assertCompletesWithoutEmitting = async (observable: Observable<any>) =>
  expect(
    await new Promise((resolve, reject) =>
      observable.subscribe({ complete: () => resolve(true), error: reject, next: reject })
    )
  ).toBe(true);
