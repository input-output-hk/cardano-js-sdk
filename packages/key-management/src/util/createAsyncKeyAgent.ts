import { AsyncKeyAgent, KeyAgent } from '../';
import { BehaviorSubject } from 'rxjs';

export const createAsyncKeyAgent = (keyAgent: KeyAgent, onShutdown?: () => void): AsyncKeyAgent => {
  const knownAddresses$ = new BehaviorSubject(keyAgent.knownAddresses);
  return {
    async deriveAddress(derivationPath) {
      const numAddresses = keyAgent.knownAddresses.length;
      const address = await keyAgent.deriveAddress(derivationPath);
      if (keyAgent.knownAddresses.length > numAddresses) {
        knownAddresses$.next(keyAgent.knownAddresses);
      }
      return address;
    },
    derivePublicKey: keyAgent.derivePublicKey.bind(keyAgent),
    knownAddresses$,
    shutdown() {
      knownAddresses$.complete();
      onShutdown?.();
    },
    signBlob: keyAgent.signBlob.bind(keyAgent),
    signTransaction: keyAgent.signTransaction.bind(keyAgent)
  };
};
