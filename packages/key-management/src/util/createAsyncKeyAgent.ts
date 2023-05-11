import { AsyncKeyAgent, KeyAgent } from '../';
import { BehaviorSubject } from 'rxjs';

export const createAsyncKeyAgent = (keyAgent: KeyAgent, onShutdown?: () => void): AsyncKeyAgent => {
  const knownAddresses$ = new BehaviorSubject(keyAgent.knownAddresses);
  return {
    async deriveAddress(derivationPath, stakeKeyDerivationIndex: number) {
      const numAddresses = keyAgent.knownAddresses.length;
      const address = await keyAgent.deriveAddress(derivationPath, stakeKeyDerivationIndex);
      if (keyAgent.knownAddresses.length > numAddresses) {
        knownAddresses$.next(keyAgent.knownAddresses);
      }
      return address;
    },
    derivePublicKey: keyAgent.derivePublicKey.bind(keyAgent),
    getBip32Ed25519: () => Promise.resolve(keyAgent.bip32Ed25519),
    getChainId: () => Promise.resolve(keyAgent.chainId),
    getExtendedAccountPublicKey: () => Promise.resolve(keyAgent.extendedAccountPublicKey),
    knownAddresses$,
    shutdown() {
      knownAddresses$.complete();
      onShutdown?.();
    },
    signBlob: keyAgent.signBlob.bind(keyAgent),
    signTransaction: keyAgent.signTransaction.bind(keyAgent)
  };
};
