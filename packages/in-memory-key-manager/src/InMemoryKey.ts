// Importing types from cardano-serialization-lib-browser will cause TypeScript errors.
import * as bip39 from 'bip39';
import CardanoSerializationLib from '@emurgo/cardano-serialization-lib-nodejs';
import { KeyManagement } from '@cardano-sdk/wallet';
import { harden } from './util';
import { Cardano } from '@cardano-sdk/core';

/**
 *
 */
export const createInMemoryKeyManager = ({
  password,
  accountIndex,
  mnemonic,
  networkId
}: {
  password: string;
  accountIndex?: number;
  mnemonic: string;
  networkId: Cardano.NetworkId;
}): KeyManagement.KeyManager => {
  if (!accountIndex) {
    accountIndex = 0;
  }

  const validMnemonic = bip39.validateMnemonic(mnemonic);
  if (!validMnemonic) throw new KeyManagement.errors.InvalidMnemonic();

  const entropy = bip39.mnemonicToEntropy(mnemonic);
  const accountPrivateKey = CardanoSerializationLib.Bip32PrivateKey.from_bip39_entropy(
    Buffer.from(entropy, 'hex'),
    Buffer.from(password)
  )
    .derive(harden(1852))
    .derive(harden(1815))
    .derive(harden(accountIndex));

  const privateParentKey = accountPrivateKey.derive(0).derive(0);
  const publicParentKey = privateParentKey.to_public();
  const publicKey = accountPrivateKey.to_public();
  const stakeKey = publicKey.derive(2).derive(0);

  return {
    deriveAddress: (addressIndex, index) => {
      const utxoPubKey = publicKey.derive(index).derive(addressIndex);
      const baseAddr = CardanoSerializationLib.BaseAddress.new(
        networkId,
        CardanoSerializationLib.StakeCredential.from_keyhash(utxoPubKey.to_raw_key().hash()),
        CardanoSerializationLib.StakeCredential.from_keyhash(stakeKey.to_raw_key().hash())
      );

      return baseAddr.to_address().to_bech32();
    },
    signMessage: async (_addressType, _signingIndex, message) => ({
      publicKey: publicParentKey.toString(),
      signature: `Signature for ${message} is not implemented yet`
    }),
    signTransaction: async (txHash: CardanoSerializationLib.TransactionHash) => {
      const witnessSet = CardanoSerializationLib.TransactionWitnessSet.new();
      const vkeyWitnesses = CardanoSerializationLib.Vkeywitnesses.new();
      const vkeyWitness = CardanoSerializationLib.make_vkey_witness(txHash, privateParentKey.to_raw_key());
      vkeyWitnesses.add(vkeyWitness);
      witnessSet.set_vkeys(vkeyWitnesses);
      return witnessSet;
    },
    stakeKey: stakeKey.to_raw_key(),
    publicKey: publicKey.to_raw_key(),
    publicParentKey: publicParentKey.to_raw_key()
  };
};
