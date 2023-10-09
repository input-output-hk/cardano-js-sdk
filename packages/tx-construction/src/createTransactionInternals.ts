import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, Serialization, util } from '@cardano-sdk/core';
import { SelectionResult } from '@cardano-sdk/input-selection';

export type CreateTxInternalsProps = {
  inputSelection: SelectionResult['selection'];
  validityInterval: Cardano.ValidityInterval;
  certificates?: Cardano.Certificate[];
  withdrawals?: Cardano.Withdrawal[];
  auxiliaryData?: Cardano.AuxiliaryData;
  collaterals?: Set<Cardano.TxIn>;
  mint?: Cardano.TokenMap;
  scriptIntegrityHash?: Crypto.Hash32ByteBase16;
  requiredExtraSignatures?: Crypto.Ed25519KeyHashHex[];
};

export const createTransactionInternals = async ({
  auxiliaryData,
  withdrawals,
  certificates,
  validityInterval,
  inputSelection,
  collaterals,
  mint,
  scriptIntegrityHash,
  requiredExtraSignatures
}: CreateTxInternalsProps): Promise<Cardano.TxBodyWithHash> => {
  const outputs = [...inputSelection.outputs];
  for (const changeOutput of inputSelection.change) {
    outputs.push(changeOutput);
  }
  const body: Cardano.TxBody = {
    auxiliaryDataHash: auxiliaryData ? Cardano.computeAuxiliaryDataHash(auxiliaryData) : undefined,
    certificates,
    fee: inputSelection.fee,
    inputs: [...inputSelection.inputs].map(([txIn]) => txIn),
    mint,
    outputs,
    requiredExtraSignatures,
    scriptIntegrityHash,
    validityInterval,
    withdrawals
  };
  if (collaterals) body.collaterals = [...collaterals];
  const serializableBody = Serialization.TransactionBody.fromCore(body);

  return {
    body,
    hash: Cardano.TransactionId.fromHexBlob(
      util.bytesToHex(Crypto.blake2b(Crypto.blake2b.BYTES).update(util.hexToBytes(serializableBody.toCbor())).digest())
    )
  };
};
