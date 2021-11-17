import * as bip39 from 'bip39';
import * as errors from './errors';
import { CSL, Cardano } from '@cardano-sdk/core';
import { KeyManager } from './types';
import { TxInternals } from '../Transaction';
import { harden, joinMnemonicWords } from './util';

export const createInMemoryKeyManager = ({
  password,
  accountIndex = 0,
  mnemonicWords,
  networkId
}: {
  password: string;
  accountIndex?: number;
  mnemonicWords: string[];
  networkId: Cardano.NetworkId;
}): KeyManager => {
  const mnemonic = joinMnemonicWords(mnemonicWords);
  const validMnemonic = bip39.validateMnemonic(mnemonic);
  if (!validMnemonic) throw new errors.InvalidMnemonic();

  const entropy = bip39.mnemonicToEntropy(mnemonic);
  const accountPrivateKey = CSL.Bip32PrivateKey.from_bip39_entropy(Buffer.from(entropy, 'hex'), Buffer.from(password))
    .derive(harden(1852))
    .derive(harden(1815))
    .derive(harden(accountIndex));
  const accountPublicKey = accountPrivateKey.to_public();
  const accountPublicKeyRaw = accountPublicKey.to_raw_key();

  const privateParentPaymentKeyRaw = accountPrivateKey.derive(0).derive(0).to_raw_key();
  const publicParentPaymentKeyRawBech32 = privateParentPaymentKeyRaw.to_public().to_bech32();

  const privateStakeKey = accountPrivateKey.derive(2).derive(0);
  const privateStakeKeyRaw = privateStakeKey.to_raw_key();
  const publicStakeKey = privateStakeKey.to_public();
  const publicStakeKeyRaw = publicStakeKey.to_raw_key();
  const publicStakeKeyRawBech32 = publicStakeKeyRaw.to_bech32();
  const publicStakeKeyRawHash = publicStakeKeyRaw.hash();

  return {
    deriveAddress: (type, addressIndex) => {
      const derivedPublicUtxoKeyHash = accountPrivateKey
        .derive(type)
        .derive(addressIndex)
        .to_public()
        .to_raw_key()
        .hash();
      const stakeKeyCredential = CSL.StakeCredential.from_keyhash(publicStakeKeyRawHash);
      const address = CSL.BaseAddress.new(
        networkId,
        CSL.StakeCredential.from_keyhash(derivedPublicUtxoKeyHash),
        stakeKeyCredential
      )
        .to_address()
        .to_bech32();

      const rewardAccount = CSL.RewardAddress.new(networkId, stakeKeyCredential).to_address().to_bech32();
      return {
        accountIndex,
        address,
        addressIndex,
        networkId,
        rewardAccount,
        type
      };
    },
    publicAccountKey: accountPublicKeyRaw,
    publicStakeKey: publicStakeKeyRaw,
    signMessage: async (_addressType, _signingIndex, message) => ({
      publicKey: accountPublicKey.toString(),
      signature: `Signature for ${message} is not implemented yet`
    }),
    signTransaction: async ({ body, hash }: TxInternals) => {
      const cslHash = CSL.TransactionHash.from_bytes(Buffer.from(hash, 'hex'));
      const paymentVkeyWitness = CSL.make_vkey_witness(cslHash, privateParentPaymentKeyRaw);
      const stakeWitnesses = (() => {
        if (!body.certificates) {
          return {};
        }
        const stakeVkeyWitness = CSL.make_vkey_witness(cslHash, privateStakeKeyRaw);
        return {
          [publicStakeKeyRawBech32]: stakeVkeyWitness.signature().to_hex()
        };
      })();
      return {
        [publicParentPaymentKeyRawBech32]: paymentVkeyWitness.signature().to_hex(),
        ...stakeWitnesses
      };
    }
  };
};
