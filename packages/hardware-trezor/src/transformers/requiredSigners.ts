import * as Crypto from '@cardano-sdk/crypto';
import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';
import { TrezorTxTransformerContext } from '../types';
import { util } from '@cardano-sdk/key-management';

export const toRequiredSigner = (
  signer: Crypto.Ed25519KeyHashHex,
  context: TrezorTxTransformerContext
): Trezor.CardanoRequiredSigner => {
  const paymentCredKnownAddress = context?.knownAddresses.find((address) => {
    const paymentCredential = Cardano.Address.fromBech32(address.address)?.asBase()?.getPaymentCredential().hash;
    return paymentCredential && paymentCredential.toString() === signer;
  });

  const stakeCredKnownAddress = context?.knownAddresses.find((address) => {
    const stakeCredential = Cardano.RewardAccount.toHash(address.rewardAccount);
    return stakeCredential && stakeCredential.toString() === signer;
  });

  const paymentKeyPath = paymentCredKnownAddress
    ? util.paymentKeyPathFromGroupedAddress(paymentCredKnownAddress)
    : null;
  const stakeKeyPath = stakeCredKnownAddress ? util.stakeKeyPathFromGroupedAddress(stakeCredKnownAddress) : null;

  return paymentKeyPath ? { keyPath: paymentKeyPath } : stakeKeyPath ? { keyPath: stakeKeyPath } : { keyHash: signer };
};

export const mapRequiredSigners = (
  signers: Crypto.Ed25519KeyHashHex[],
  context: TrezorTxTransformerContext
): Trezor.CardanoRequiredSigner[] => signers.map((signer) => toRequiredSigner(signer, context));
