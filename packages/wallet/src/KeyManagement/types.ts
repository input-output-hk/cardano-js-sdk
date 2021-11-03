import { Address } from '..';
import { CSL, Cardano } from '@cardano-sdk/core';

export interface KeyManager {
  deriveAddress: (addressIndex: number, index: 0 | 1) => string;
  signMessage: (
    addressType: Address.AddressType,
    signingIndex: number,
    message: string
  ) => Promise<{ publicKey: string; signature: string }>;
  // TODO: do not expose CSL objects publicly
  publicKey: CSL.PublicKey;
  publicParentKey: CSL.PublicKey;
  // TODO: make signatures object key type clear with type alias
  signTransaction: (txHash: Cardano.Hash16) => Promise<Cardano.Witness['signatures']>;
  stakeKey: CSL.PublicKey;
}
