import * as Crypto from '@cardano-sdk/crypto';
import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../types';
import { Transform, areStringsEqualInConstantTime } from '@cardano-sdk/util';
import { util } from '@cardano-sdk/key-management';

export const toRequiredSigner: Transform<
  Crypto.Ed25519KeyHashHex,
  Ledger.RequiredSigner,
  LedgerTxTransformerContext
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
      path: paymentKeyPath,
      type: Ledger.TxRequiredSignerType.PATH
    };
  }

  if (stakeKeyPath) {
    return {
      path: stakeKeyPath,
      type: Ledger.TxRequiredSignerType.PATH
    };
  }

  return {
    hashHex: keyHash,
    type: Ledger.TxRequiredSignerType.HASH
  };
};

export const mapRequiredSigners = (
  signers: Crypto.Ed25519KeyHashHex[] | undefined,
  context: LedgerTxTransformerContext
): Ledger.RequiredSigner[] | null => (signers ? signers.map((signer) => toRequiredSigner(signer, context)) : null);
