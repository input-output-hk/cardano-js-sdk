import { Cardano, TxCBOR } from '@cardano-sdk/core';
import { FinalizeTxDependencies, SignedTx, TxContext } from './types';
import {
  SignTransactionOptions,
  TransactionSigner,
  Witnesser,
  util as keyManagementUtil
} from '@cardano-sdk/key-management';
import { filter, firstValueFrom } from 'rxjs';

const getSignatures = async (
  addressManager: keyManagementUtil.Bip32Ed25519AddressManager,
  witnesser: Witnesser,
  txInternals: Cardano.TxBodyWithHash,
  extraSigners?: TransactionSigner[],
  signingOptions?: SignTransactionOptions
) => {
  // Wait until the async key agent has at least one known addresses.
  await firstValueFrom(addressManager.knownAddresses$.pipe(filter((addresses) => addresses.length > 0)));
  const { signatures } = await witnesser.witness(txInternals, signingOptions);

  if (extraSigners) {
    for (const extraSigner of extraSigners) {
      const extraSignature = await extraSigner.sign(txInternals);
      signatures.set(extraSignature.pubKey, extraSignature.signature);
    }
  }

  return signatures;
};

export const finalizeTx = async (
  tx: Cardano.TxBodyWithHash,
  { ownAddresses, witness, signingOptions, auxiliaryData, isValid, handleResolutions }: TxContext,
  { inputResolver, addressManager, witnesser }: FinalizeTxDependencies,
  stubSign = false
): Promise<SignedTx> => {
  const signatures = stubSign
    ? await keyManagementUtil.stubSignTransaction({
        dRepPublicKey: await addressManager.derivePublicKey(keyManagementUtil.DREP_KEY_DERIVATION_PATH),
        extraSigners: witness?.extraSigners,
        inputResolver,
        knownAddresses: ownAddresses,
        signTransactionOptions: signingOptions,
        txBody: tx.body
      })
    : await getSignatures(addressManager, witnesser, tx, witness?.extraSigners, signingOptions);

  const transaction = {
    auxiliaryData,
    body: tx.body,
    id: tx.hash,
    isValid,
    witness: {
      ...witness,
      signatures: new Map([...signatures.entries(), ...(witness?.signatures?.entries() || [])])
    }
  };

  return {
    cbor: TxCBOR.serialize(transaction),
    context: {
      handleResolutions: handleResolutions ?? []
    },
    tx: transaction
  };
};
