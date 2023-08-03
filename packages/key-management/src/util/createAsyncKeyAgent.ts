import { AsyncKeyAgent, GroupedAddress, InMemoryKeyAgent, KeyAgent } from '../';
import { BehaviorSubject } from 'rxjs';
import { NotImplementedError } from '@cardano-sdk/core';

export const createAsyncKeyAgent = (keyAgent: KeyAgent, onShutdown?: () => void): AsyncKeyAgent => {
  const knownAddresses$ = new BehaviorSubject(keyAgent.knownAddresses);
  return {
    async deriveAddress(derivationPath, stakeKeyDerivationIndex: number, pure?: boolean) {
      const numAddresses = keyAgent.knownAddresses.length;
      const address = await keyAgent.deriveAddress(derivationPath, stakeKeyDerivationIndex, pure);

      if (keyAgent.knownAddresses.length > numAddresses && !pure) {
        knownAddresses$.next(keyAgent.knownAddresses);
      }

      return address;
    },
    derivePublicKey: keyAgent.derivePublicKey.bind(keyAgent),
    async exportRootPrivateKey() {
      if (keyAgent instanceof InMemoryKeyAgent) return keyAgent.exportRootPrivateKey();
      throw new NotImplementedError('exportRootPrivateKey is not implemented for this key agent');
    },
    getBip32Ed25519: () => Promise.resolve(keyAgent.bip32Ed25519),
    getChainId: () => Promise.resolve(keyAgent.chainId),
    getExtendedAccountPublicKey: () => Promise.resolve(keyAgent.extendedAccountPublicKey),
    knownAddresses$,
    setKnownAddresses: async (addresses: GroupedAddress[]): Promise<void> => {
      keyAgent.knownAddresses = addresses;
      knownAddresses$.next(keyAgent.knownAddresses);
    },
    shutdown() {
      knownAddresses$.complete();
      onShutdown?.();
    },
    signBlob: keyAgent.signBlob.bind(keyAgent),
    signTransaction: keyAgent.signTransaction.bind(keyAgent)
  };
};
