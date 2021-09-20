import CardanoSerializationLib from '@emurgo/cardano-serialization-lib-nodejs';
import { Address } from '../';

export interface KeyManager {
  signMessage: (
    addressType: Address.AddressType,
    signingIndex: number,
    message: string
  ) => Promise<{ publicKey: string; signature: string }>;
  publicKey: CardanoSerializationLib.PublicKey;
  publicParentKey: CardanoSerializationLib.PublicKey;
  signTransaction: (
    txHash: CardanoSerializationLib.TransactionHash
  ) => Promise<CardanoSerializationLib.TransactionWitnessSet>;
}
