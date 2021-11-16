import * as bip39 from 'bip39';
import * as errors from './errors';
import { CSL, Cardano } from '@cardano-sdk/core';
import { KeyManager } from './types';
import { TxInternals } from '../Transaction';
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

  const privateParentPaymentKey = accountPrivateKey.derive(0).derive(0);
  const publicParentPaymentKey = privateParentPaymentKey.to_public();
  const publicPaymentKey = accountPrivateKey.to_public();

  const privateStakeKey = accountPrivateKey.derive(2).derive(0);
  const publicStakeKey = privateStakeKey.to_public();
  const publicRawSakeKey = publicStakeKey.to_raw_key();
  const stakeKeyCredential = CSL.StakeCredential.from_keyhash(publicRawSakeKey.hash());

  return {
    deriveAddress: (addressIndex, index) => {
      const utxoPubKey = publicPaymentKey.derive(index).derive(addressIndex);
      const baseAddr = CSL.BaseAddress.new(
        networkId,
        CSL.StakeCredential.from_keyhash(utxoPubKey.to_raw_key().hash()),
        stakeKeyCredential
      );

      return baseAddr.to_address().to_bech32();
    },
    publicKey: publicPaymentKey.to_raw_key(),
    publicParentKey: publicParentPaymentKey.to_raw_key(),
    rewardAccount: CSL.RewardAddress.new(networkId, stakeKeyCredential).to_address().to_bech32(),
    signMessage: async (_addressType, _signingIndex, message) => ({
      publicKey: publicParentPaymentKey.toString(),
      signature: `Signature for ${message} is not implemented yet`
    }),
    signTransaction: async ({ body, hash }: TxInternals) => {
      const cslHash = CSL.TransactionHash.from_bytes(Buffer.from(hash, 'hex'));
      const paymentVkeyWitness = CSL.make_vkey_witness(cslHash, privateParentPaymentKey.to_raw_key());
      const stakeWitnesses = (() => {
        if (!body.certificates) {
          return {};
        }
        const stakeVkeyWitness = CSL.make_vkey_witness(cslHash, privateStakeKey.to_raw_key());
        return {
          [stakeVkeyWitness.vkey().public_key().to_bech32()]: stakeVkeyWitness.signature().to_hex()
        };
      })();
      return {
        [paymentVkeyWitness.vkey().public_key().to_bech32()]: paymentVkeyWitness.signature().to_hex(),
        ...stakeWitnesses
      };
    },
    stakeKey: publicRawSakeKey
  };
};
