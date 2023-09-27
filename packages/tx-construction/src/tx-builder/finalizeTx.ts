import {
  AsyncKeyAgent,
  SignTransactionOptions,
  TransactionSigner,
  util as keyManagementUtil
} from '@cardano-sdk/key-management';
import { Cardano, TxCBOR } from '@cardano-sdk/core';
import { FinalizeTxDependencies, SignedTx, TxContext } from './types';
import { filter, firstValueFrom } from 'rxjs';

const getSignatures = async (
  keyAgent: AsyncKeyAgent,
  txInternals: Cardano.TxBodyWithHash,
  extraSigners?: TransactionSigner[],
  signingOptions?: SignTransactionOptions
) => {
  // Wait until the async key agent has at least one known addresses.
  await firstValueFrom(keyAgent.knownAddresses$.pipe(filter((addresses) => addresses.length > 0)));
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
  { ownAddresses, witness, signingOptions, auxiliaryData, isValid, handleResolutions }: TxContext,
  { inputResolver, keyAgent }: FinalizeTxDependencies,
  stubSign = false
): Promise<SignedTx> => {
  const signatures = stubSign
    ? await keyManagementUtil.stubSignTransaction({
        dRepPublicKey: await keyAgent.derivePublicKey(keyManagementUtil.DREP_KEY_DERIVATION_PATH),
        extraSigners: witness?.extraSigners,
        inputResolver,
        knownAddresses: ownAddresses,
        signTransactionOptions: signingOptions,
        txBody: tx.body
      })
    : await getSignatures(keyAgent, tx, witness?.extraSigners, signingOptions);

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
