import { GetPassword } from './types';
import { Milliseconds } from '..';

export const cachedGetPassword = (getPassword: () => Promise<Uint8Array>, cacheDuration: Milliseconds): GetPassword => {
  let cached: Promise<Uint8Array> | null;
  let timeout: NodeJS.Timeout | null;
  return (noCache) => {
    if (noCache || !cached) {
      cached = getPassword()
        .then((password) => {
          if (timeout) clearTimeout(timeout);
          timeout = setTimeout(() => (cached = null), cacheDuration);
          return password;
        })
        .catch((error) => {
          cached = null;
          throw error;
        });
    }
    return cached;
  };
};
