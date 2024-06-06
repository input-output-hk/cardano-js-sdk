import { Cardano } from '@cardano-sdk/core';
import { areStringsEqualInConstantTime } from '@cardano-sdk/util';
import { util } from '@cardano-sdk/key-management';
import type * as Crypto from '@cardano-sdk/crypto';
import type * as Trezor from '@trezor/connect';
import type { Transform } from '@cardano-sdk/util';
import type { TrezorTxTransformerContext } from '../types.js';

export const toRequiredSigner: Transform<
  Crypto.Ed25519KeyHashHex,
  Trezor.CardanoRequiredSigner,
  TrezorTxTransformerContext
> = (keyHash, context) => {
  const paymentCredKnownAddress = context?.knownAddresses.find((address) => {
    const paymentCredential = Cardano.Address.fromBech32(address.address)?.asBase()?.getPaymentCredential().hash;
    return !!paymentCredential && areStringsEqualInConstantTime(paymentCredential.toString(), keyHash);
  });

  const stakeCredKnownAddress = context?.knownAddresses.find((address) => {
    const stakeCredential = Cardano.RewardAccount.toHash(address.rewardAccount);
    return !!stakeCredential && areStringsEqualInConstantTime(stakeCredential.toString(), keyHash);
  });

  const paymentKeyPath = paymentCredKnownAddress
    ? util.paymentKeyPathFromGroupedAddress(paymentCredKnownAddress)
    : null;
  const stakeKeyPath = stakeCredKnownAddress ? util.stakeKeyPathFromGroupedAddress(stakeCredKnownAddress) : null;

  if (paymentKeyPath) {
    return {
      keyHash: undefined,
      keyPath: paymentKeyPath
    };
  }

  if (stakeKeyPath) {
    return {
      keyHash: undefined,
      keyPath: stakeKeyPath
    };
  }

  return {
    keyHash,
    keyPath: undefined
  };
};

export const mapRequiredSigners = (
  signers: Crypto.Ed25519KeyHashHex[],
  context: TrezorTxTransformerContext
): Trezor.CardanoRequiredSigner[] => signers.map((signer) => toRequiredSigner(signer, context));
