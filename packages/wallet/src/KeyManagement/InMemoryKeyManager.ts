import * as bip39 from 'bip39';
import * as errors from './errors';
import { CSL, Cardano } from '@cardano-sdk/core';
import { KeyManager } from './types';
import { harden, joinMnemonicWords } from './util';

export const createInMemoryKeyManager = ({
  password,
  accountIndex,
  mnemonicWords,
  networkId
}: {
  password: string;
  accountIndex?: number;
  mnemonicWords: string[];
  networkId: Cardano.NetworkId;
}): KeyManager => {
  if (!accountIndex) {
    accountIndex = 0;
  }

  const mnemonic = joinMnemonicWords(mnemonicWords);
  const validMnemonic = bip39.validateMnemonic(mnemonic);
  if (!validMnemonic) throw new errors.InvalidMnemonic();

  const entropy = bip39.mnemonicToEntropy(mnemonic);
  const accountPrivateKey = CSL.Bip32PrivateKey.from_bip39_entropy(Buffer.from(entropy, 'hex'), Buffer.from(password))
    .derive(harden(1852))
    .derive(harden(1815))
    .derive(harden(accountIndex));

  const privateParentKey = accountPrivateKey.derive(0).derive(0);
  const publicParentKey = privateParentKey.to_public();
  const publicKey = accountPrivateKey.to_public();

  const stakeKey = publicKey.derive(2).derive(0);
  const stakeKeyRaw = stakeKey.to_raw_key();
  const stakeKeyCredential = CSL.StakeCredential.from_keyhash(stakeKeyRaw.hash());

  return {
    deriveAddress: (addressIndex, index) => {
      const utxoPubKey = publicKey.derive(index).derive(addressIndex);
      const baseAddr = CSL.BaseAddress.new(
        networkId,
        CSL.StakeCredential.from_keyhash(utxoPubKey.to_raw_key().hash()),
        stakeKeyCredential
      );

      return baseAddr.to_address().to_bech32();
    },
    publicKey: publicKey.to_raw_key(),
    publicParentKey: publicParentKey.to_raw_key(),
    rewardAccount: CSL.RewardAddress.new(networkId, stakeKeyCredential).to_address().to_bech32(),
    signMessage: async (_addressType, _signingIndex, message) => ({
      publicKey: publicParentKey.toString(),
      signature: `Signature for ${message} is not implemented yet`
    }),
    signTransaction: async (txHash: Cardano.Hash16) => {
      const cslHash = CSL.TransactionHash.from_bytes(Buffer.from(txHash, 'hex'));
      const vkeyWitness = CSL.make_vkey_witness(cslHash, privateParentKey.to_raw_key());
      return {
        [vkeyWitness.vkey().public_key().to_bech32()]: vkeyWitness.signature().to_hex()
      };
    },
    stakeKey: stakeKeyRaw
  };
};
