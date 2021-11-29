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
  const extendedAccountPrivateKey = CSL.Bip32PrivateKey.from_bip39_entropy(
    Buffer.from(entropy, 'hex'),
    Buffer.from(password)
  )
    .derive(harden(1852))
    .derive(harden(1815))
    .derive(harden(accountIndex));
  const extendedAccountPublicKey = extendedAccountPrivateKey.to_public();

  const privateParentPaymentKeyRaw = extendedAccountPrivateKey.derive(0).derive(0).to_raw_key();
  const publicParentPaymentKeyRawHex = Cardano.Ed25519PublicKey(
    Buffer.from(privateParentPaymentKeyRaw.to_public().as_bytes()).toString('hex')
  );

  const privateStakeKey = extendedAccountPrivateKey.derive(2).derive(0);
  const privateStakeKeyRaw = privateStakeKey.to_raw_key();
  const publicStakeKey = privateStakeKey.to_public();
  const publicStakeKeyRaw = publicStakeKey.to_raw_key();
  const publicStakeKeyRawHex = Cardano.Ed25519PublicKey(Buffer.from(publicStakeKeyRaw.as_bytes()).toString('hex'));
  const publicStakeKeyRawHash = publicStakeKeyRaw.hash();

  return {
    deriveAddress: (type, addressIndex) => {
      const derivedPublicPaymentKeyHash = extendedAccountPrivateKey
        .derive(type)
        .derive(addressIndex)
        .to_public()
        .to_raw_key()
        .hash();
      const stakeKeyCredential = CSL.StakeCredential.from_keyhash(publicStakeKeyRawHash);
      const address = CSL.BaseAddress.new(
        networkId,
        CSL.StakeCredential.from_keyhash(derivedPublicPaymentKeyHash),
        stakeKeyCredential
      ).to_address();

      const rewardAccount = CSL.RewardAddress.new(networkId, stakeKeyCredential).to_address();
      return {
        accountIndex,
        address: Cardano.Address(address.to_bech32()),
        addressIndex,
        networkId,
        rewardAccount: Cardano.RewardAccount(rewardAccount.to_bech32()),
        type
      };
    },
    derivePublicKey: (type, addressIndex) => extendedAccountPublicKey.derive(type).derive(addressIndex).to_raw_key(),
    extendedAccountPublicKey,
    signMessage: async (_addressType, _signingIndex, message) => ({
      publicKey: extendedAccountPublicKey.toString(),
      signature: `Signature for ${message} is not implemented yet`
    }),
    signTransaction: async ({ body, hash }: TxInternals) => {
      const cslHash = CSL.TransactionHash.from_bytes(Buffer.from(hash, 'hex'));
      const paymentVkeyWitness = CSL.make_vkey_witness(cslHash, privateParentPaymentKeyRaw);
      const stakeWitnesses = (() => {
        if (!body.certificates) {
          return [];
        }
        const stakeVkeyWitness = CSL.make_vkey_witness(cslHash, privateStakeKeyRaw);
        return [[publicStakeKeyRawHex, Cardano.Ed25519Signature(stakeVkeyWitness.signature().to_hex())] as const];
      })();
      const paymentVkeyWitnessHex = Cardano.Ed25519Signature(paymentVkeyWitness.signature().to_hex());
      return new Map<Cardano.Ed25519PublicKey, Cardano.Ed25519Signature>([
        [publicParentPaymentKeyRawHex, paymentVkeyWitnessHex],
        ...stakeWitnesses
      ]);
    }
  };
};
