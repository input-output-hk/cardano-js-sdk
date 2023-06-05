import * as Crypto from '@cardano-sdk/crypto';
import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../types';
import { Transform } from '@cardano-sdk/util';
import { paymentKeyPathFromGroupedAddress, stakeKeyPathFromGroupedAddress } from './keyPaths';

export const toRequiredSigner: Transform<
  Crypto.Ed25519KeyHashHex,
  Ledger.RequiredSigner,
  LedgerTxTransformerContext
> = (keyHash, context) => {
  const paymentCredKnownAddress = context?.knownAddresses.find((address) => {
    const paymentCredential = Cardano.Address.fromBech32(address.address)?.asBase()?.getPaymentCredential().hash;
    return paymentCredential && paymentCredential.toString() === keyHash;
  });

  const stakeCredKnownAddress = context?.knownAddresses.find((address) => {
    const stakingCredential = Cardano.RewardAccount.toHash(address.rewardAccount);
    return stakingCredential && stakingCredential.toString() === keyHash;
  });

  const paymentPath = paymentCredKnownAddress ? paymentKeyPathFromGroupedAddress(paymentCredKnownAddress) : null;
  const stakingPath = stakeCredKnownAddress ? stakeKeyPathFromGroupedAddress(stakeCredKnownAddress) : null;

  if (paymentPath) {
    return {
      path: paymentPath,
      type: Ledger.TxRequiredSignerType.PATH
    };
  }

  if (stakingPath) {
    return {
      path: stakingPath,
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
