import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress } from '../types';
import { HexBlob } from '@cardano-sdk/util';

export type CoseSign1CborHex = HexBlob;
export type CoseKeyCborHex = HexBlob;

export interface Cip8SignDataContext {
  knownAddresses: GroupedAddress[];
  signWith: Cardano.PaymentAddress | Cardano.RewardAccount | Cardano.DRepID;
  payload: HexBlob;
}

export interface Cip8SignResult {
  publicKey: Crypto.Ed25519PublicKeyHex;
  signature: Crypto.Ed25519SignatureHex;
}
