import { Cardano, Serialization, TxCBOR } from '@cardano-sdk/core';
import { FinalizeTxDependencies, SignedTx, TxContext } from './types';
import {
  SignTransactionContext,
  SignTransactionOptions,
  TransactionSigner,
  Witnesser,
  util as keyManagementUtil
} from '@cardano-sdk/key-management';

const getSignatures = async (
  witnesser: Witnesser,
  txInternals: Cardano.TxBodyWithHash,
  signingContext: SignTransactionContext,
  signingOptions?: SignTransactionOptions,
  extraSigners?: TransactionSigner[]
) => {
  const { signatures } = await witnesser.witness(
    new Serialization.Transaction(
      Serialization.TransactionBody.fromCore(txInternals.body),
      new Serialization.TransactionWitnessSet()
    ),
    signingContext,
    signingOptions
  );

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
  { witness, signingOptions, signingContext, auxiliaryData, isValid, handleResolutions }: TxContext,
  { dRepPublicKey, witnesser }: FinalizeTxDependencies,
  stubSign = false
): Promise<SignedTx> => {
  const signatures = stubSign
    ? await keyManagementUtil.stubSignTransaction({
        context: signingContext,
        dRepPublicKey,
        extraSigners: witness?.extraSigners,
        signTransactionOptions: signingOptions,
        txBody: tx.body
      })
    : await getSignatures(witnesser, tx, signingContext, signingOptions, witness?.extraSigners);

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
