import type { AsyncKeyAgent, KeyAgent } from '../types.js';

export const createAsyncKeyAgent = (keyAgent: KeyAgent, onShutdown?: () => void): AsyncKeyAgent => ({
  deriveAddress(derivationPath, stakeKeyDerivationIndex: number) {
    return keyAgent.deriveAddress(derivationPath, stakeKeyDerivationIndex);
  },
  derivePublicKey: keyAgent.derivePublicKey.bind(keyAgent),
  getAccountIndex: () => Promise.resolve(keyAgent.accountIndex),
  getBip32Ed25519: () => Promise.resolve(keyAgent.bip32Ed25519),
  getChainId: () => Promise.resolve(keyAgent.chainId),
  getExtendedAccountPublicKey: () => Promise.resolve(keyAgent.extendedAccountPublicKey),
  shutdown() {
    onShutdown?.();
  },
  signBlob: keyAgent.signBlob.bind(keyAgent),
  signTransaction: keyAgent.signTransaction.bind(keyAgent)
});
