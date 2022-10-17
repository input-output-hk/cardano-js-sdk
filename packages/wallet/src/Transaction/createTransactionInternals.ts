import { CSL, Cardano, coreToCsl, util } from '@cardano-sdk/core';
import { SelectionResult } from '@cardano-sdk/input-selection';
import { usingAutoFree } from '@cardano-sdk/util';

export type CreateTxInternalsProps = {
  changeAddress: Cardano.Address;
  inputSelection: SelectionResult['selection'];
  validityInterval: Cardano.ValidityInterval;
  certificates?: Cardano.Certificate[];
  withdrawals?: Cardano.Withdrawal[];
  auxiliaryData?: Cardano.AuxiliaryData;
  collaterals?: Set<Cardano.NewTxIn>;
  mint?: Cardano.TokenMap;
  scriptIntegrityHash?: Cardano.util.Hash32ByteBase16;
  requiredExtraSignatures?: Cardano.Ed25519KeyHash[];
};

export const createTransactionInternals = async ({
  auxiliaryData,
  changeAddress,
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
    for (const value of inputSelection.change) {
      outputs.push({
        address: changeAddress,
        value
      });
    }
    const body: Cardano.NewTxBodyAlonzo = {
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
    const cslBody = coreToCsl.txBody(scope, body, auxiliaryData);

    return {
      body,
      hash: Cardano.TransactionId.fromHexBlob(util.bytesToHex(scope.manage(CSL.hash_transaction(cslBody)).to_bytes()))
    };
  });
