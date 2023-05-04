import {
  AsyncKeyAgent,
  SignTransactionOptions,
  TransactionSigner,
  util as keyManagementUtil
} from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { FinalizeTxDependencies, SignedTx, TxContext } from './types';

const getSignatures = async (
  keyAgent: AsyncKeyAgent,
  txInternals: Cardano.TxBodyWithHash,
  extraSigners?: TransactionSigner[],
  signingOptions?: SignTransactionOptions
) => {
  const signatures: Cardano.Signatures = await keyAgent.signTransaction(txInternals, signingOptions);

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
  { ownAddresses, witness, signingOptions, auxiliaryData, isValid }: TxContext,
  { inputResolver, keyAgent }: FinalizeTxDependencies,
  stubSign = false
): Promise<SignedTx> => {
  const signatures = stubSign
    ? await keyManagementUtil.stubSignTransaction(
        tx.body,
        ownAddresses,
        inputResolver,
        witness?.extraSigners,
        signingOptions
      )
    : await getSignatures(keyAgent, tx, witness?.extraSigners, signingOptions);

  return {
    tx: {
      auxiliaryData,
      body: tx.body,
      id: tx.hash,
      isValid,
      witness: {
        ...witness,
        signatures: new Map([...signatures.entries(), ...(witness?.signatures?.entries() || [])])
      }
    }
  };
};
