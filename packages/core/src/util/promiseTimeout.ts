/* eslint-disable promise/param-names */

import { TimeoutError } from '../errors';

export const promiseTimeout = <T>(promise: Promise<T>, timeout: number) => {
  let timeoutId: NodeJS.Timeout;

  return Promise.race([
    promise,
    new Promise<T>(
      (_, reject) =>
        (timeoutId = setTimeout(() => reject(new TimeoutError('Failed to resolve the promise in time')), timeout))
    )
  ]).finally(() => {
    if (timeoutId) clearTimeout(timeoutId);
  });
};
