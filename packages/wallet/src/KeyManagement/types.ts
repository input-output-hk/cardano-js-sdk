import { AddressType } from '..';
import { CSL, Cardano } from '@cardano-sdk/core';
import { TxInternals } from '../Transaction';

export interface KeyManager {
  deriveAddress: (addressIndex: number, index: 0 | 1) => string;
  signMessage: (
    addressType: AddressType,
    signingIndex: number,
    message: string
  ) => Promise<{ publicKey: string; signature: string }>;
  // TODO: do not expose CSL objects publicly
  publicKey: CSL.PublicKey;
  publicParentKey: CSL.PublicKey;
  // TODO: make signatures object key type clear with type alias
  signTransaction: (tx: TxInternals) => Promise<Cardano.Witness['signatures']>;
  stakeKey: CSL.PublicKey;
  rewardAccount: Cardano.Address;
}
