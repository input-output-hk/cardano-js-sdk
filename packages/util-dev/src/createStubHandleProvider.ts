import { Cardano, HandleProvider } from '@cardano-sdk/core';
import delay from 'delay';

/**
 * @returns provider that fails to resolve all handles
 */
export const createStubHandleProvider = (delayMs?: number): HandleProvider => ({
  getPolicyIds: async () => {
    if (delayMs) await delay(delayMs);
    // Kora labs testnet policy id
    return [Cardano.PolicyId('8d18d786e92776c824607fd8e193ec535c79dc61ea2405ddf3b09fe3')];
  },
  healthCheck: async () => {
    if (delayMs) await delay(delayMs);
    return { ok: true };
  },
  resolveHandles: async ({ handles }) => {
    if (delayMs) await delay(delayMs);
    return handles.map(() => null);
  }
});
