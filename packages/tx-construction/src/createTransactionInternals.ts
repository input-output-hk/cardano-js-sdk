import * as Crypto from '@cardano-sdk/crypto';
import { CML, Cardano, coreToCml, util } from '@cardano-sdk/core';
import { SelectionResult } from '@cardano-sdk/input-selection';
import { usingAutoFree } from '@cardano-sdk/util';

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
}: CreateTxInternalsProps): Promise<Cardano.TxBodyWithHash> =>
  usingAutoFree((scope) => {
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
    const cslBody = coreToCml.txBody(scope, body);

    return {
      body,
      hash: Cardano.TransactionId.fromHexBlob(util.bytesToHex(scope.manage(CML.hash_transaction(cslBody)).to_bytes()))
    };
  });
