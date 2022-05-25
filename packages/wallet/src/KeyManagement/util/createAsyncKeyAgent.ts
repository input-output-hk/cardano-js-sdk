import { AsyncKeyAgent, KeyAgent } from '../types';
import { BehaviorSubject } from 'rxjs';

export const createAsyncKeyAgent = (keyAgent: KeyAgent): AsyncKeyAgent => {
  const knownAddresses$ = new BehaviorSubject(keyAgent.knownAddresses);
  return {
    async deriveAddress(derivationPath) {
      const address = await keyAgent.deriveAddress(derivationPath);
      knownAddresses$.next(keyAgent.knownAddresses);
      return address;
    },
    knownAddresses$,
    signBlob: keyAgent.signBlob.bind(keyAgent),
    signTransaction: keyAgent.signTransaction.bind(keyAgent)
  };
};
