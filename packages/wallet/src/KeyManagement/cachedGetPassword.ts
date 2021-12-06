import { GetPassword } from './types';
import { Milliseconds } from '..';

export const cachedGetPassword = (getPassword: () => Promise<Uint8Array>, cacheDuration: Milliseconds): GetPassword => {
  let cached: Uint8Array | null;
  let timeout: NodeJS.Timeout | null;
  return async (noCache) => {
    if (noCache || !cached) {
      cached = await getPassword();
      if (timeout) clearTimeout(timeout);
      timeout = setTimeout(() => (cached = null), cacheDuration);
    }
    return cached;
  };
};
