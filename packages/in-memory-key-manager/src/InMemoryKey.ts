// Importing types from cardano-serialization-lib-browser will cause TypeScript errors.
import * as bip39 from 'bip39';
import CardanoSerializationLib from '@emurgo/cardano-serialization-lib-nodejs';
import { KeyManagement } from '@cardano-sdk/wallet';
import { harden } from './util';

/**
 *
 */
export const createInMemoryKeyManager = ({
  password,
  accountIndex,
  mnemonic
}: {
  password: string;
  accountIndex?: number;
  mnemonic: string;
}): KeyManagement.KeyManager => {
  if (!accountIndex) {
    accountIndex = 0;
  }

  const validMnemonic = bip39.validateMnemonic(mnemonic);
  if (!validMnemonic) throw new KeyManagement.errors.InvalidMnemonic();

  const entropy = bip39.mnemonicToEntropy(mnemonic);
  const account = CardanoSerializationLib.Bip32PrivateKey.from_bip39_entropy(
    Buffer.from(entropy, 'hex'),
    Buffer.from(password)
  )
    .derive(harden(1852))
    .derive(harden(1815))
    .derive(harden(accountIndex));

  const privateParentKey = account.derive(0).derive(0);
  const publicParentKey = privateParentKey.to_public().to_raw_key();

  return {
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
    publicKey: account.to_public().to_raw_key(),
    publicParentKey
  };
};
