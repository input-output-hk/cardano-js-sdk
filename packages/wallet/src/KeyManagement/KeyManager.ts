import { CSL } from '@cardano-sdk/cardano-serialization-lib';
import { Address } from '../';

export interface KeyManager {
  deriveAddress: (addressIndex: number, index: 0 | 1) => string;
  signMessage: (
    addressType: Address.AddressType,
    signingIndex: number,
    message: string
  ) => Promise<{ publicKey: string; signature: string }>;
  publicKey: CSL.PublicKey;
  publicParentKey: CSL.PublicKey;
  signTransaction: (txHash: CSL.TransactionHash) => Promise<CSL.TransactionWitnessSet>;
  stakeKey: CSL.PublicKey;
}
