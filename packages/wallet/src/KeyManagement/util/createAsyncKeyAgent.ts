import { AsyncKeyAgent, KeyAgent } from '../types';

export const createAsyncKeyAgent = (keyAgent: KeyAgent): AsyncKeyAgent => ({
  deriveAddress: keyAgent.deriveAddress.bind(keyAgent),
  getKnownAddresses: async () => keyAgent.knownAddresses,
  signBlob: keyAgent.signBlob.bind(keyAgent),
  signTransaction: keyAgent.signTransaction.bind(keyAgent)
});
