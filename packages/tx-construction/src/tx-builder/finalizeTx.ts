import {
  AsyncKeyAgent,
  GroupedAddress,
  SignTransactionOptions,
  TransactionSigner,
  util as keyManagementUtil
} from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';

import { FinalizeTxDependencies, FinalizeTxProps } from '../types';

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
  props: FinalizeTxProps & { addresses: GroupedAddress[] },
  { inputResolver, keyAgent }: FinalizeTxDependencies,
  stubSign = false
): Promise<Cardano.Tx> => {
  const signatures = stubSign
    ? await keyManagementUtil.stubSignTransaction(
        props.tx.body,
        props.addresses,
        inputResolver,
        props.witness?.extraSigners,
        props.signingOptions
      )
    : await getSignatures(keyAgent, props.tx, props.witness?.extraSigners, props.signingOptions);
  return {
    auxiliaryData: props.auxiliaryData,
    body: props.tx.body,
    id: props.tx.hash,
    isValid: props.isValid,
    witness: {
      ...props.witness,
      scripts: props.scripts,
      signatures
    }
  };
};
