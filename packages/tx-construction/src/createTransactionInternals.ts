import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, Serialization, util } from '@cardano-sdk/core';
import { computeScriptDataHash } from './computeScriptDataHash.js';
import { getDefaultCostModelsForVersions } from './tx-builder/costModels.js';
import type { SelectionResult } from '@cardano-sdk/input-selection';
import type { TxBodyPreInputSelection } from './types.js';

export type CreateTxInternalsProps = {
  inputSelection: SelectionResult['selection'];
  referenceInputs?: Set<Cardano.TxIn>;
  validityInterval: Cardano.ValidityInterval;
  certificates?: Cardano.Certificate[];
  withdrawals?: Cardano.Withdrawal[];
  auxiliaryData?: Cardano.AuxiliaryData;
  collaterals?: Set<Cardano.TxIn>;
  collateralReturn?: Cardano.TxOut;
  mint?: Cardano.TokenMap;
  scriptIntegrityHash?: Crypto.Hash32ByteBase16;
  requiredExtraSignatures?: Crypto.Ed25519KeyHashHex[];
};

/** Returns transaction body based on the information available before input selection takes place */
export const createPreInputSelectionTxBody = ({
  auxiliaryData,
  withdrawals,
  certificates,
  validityInterval,
  collaterals,
  collateralReturn,
  mint,
  scriptIntegrityHash,
  referenceInputs,
  requiredExtraSignatures,
  outputs
}: Omit<CreateTxInternalsProps, 'inputSelection'> & { outputs?: Cardano.TxOut[] }): {
  txBody: TxBodyPreInputSelection;
  auxiliaryData?: Cardano.AuxiliaryData;
} => ({
  auxiliaryData,
  txBody: {
    auxiliaryDataHash: auxiliaryData ? Cardano.computeAuxiliaryDataHash(auxiliaryData) : undefined,
    certificates,
    mint,
    outputs: outputs || [],
    referenceInputs: referenceInputs ? [...referenceInputs] : undefined,
    requiredExtraSignatures,
    scriptIntegrityHash,
    validityInterval,
    ...(withdrawals?.length && { withdrawals }),
    ...(collaterals?.size && { collaterals: [...collaterals] }),
    collateralReturn
  }
});

/** Updates the txBody after input selection takes place with the calculated change and selected inputs */
export const includeChangeAndInputs = ({
  bodyPreInputSelection,
  inputSelection,
  scriptVersions,
  witness
}: Pick<CreateTxInternalsProps, 'inputSelection'> & {
  bodyPreInputSelection: TxBodyPreInputSelection;
  witness?: Cardano.Witness;
  scriptVersions?: Set<Cardano.PlutusLanguageVersion>;
}): Cardano.TxBodyWithHash => {
  const body: Cardano.TxBody = {
    ...bodyPreInputSelection,
    fee: inputSelection.fee,
    inputs: [...inputSelection.inputs].map(([txIn]) => txIn),
    outputs: [...inputSelection.outputs, ...inputSelection.change]
  };

  if (scriptVersions && witness) {
    const costModels = getDefaultCostModelsForVersions([...scriptVersions]);
    body.scriptIntegrityHash = computeScriptDataHash(
      costModels,
      [...scriptVersions],
      witness.redeemers,
      witness.datums
    );
  }

  const serializableBody = Serialization.TransactionBody.fromCore(body);

  return {
    body,
    hash: Cardano.TransactionId.fromHexBlob(
      util.bytesToHex(Crypto.blake2b(Crypto.blake2b.BYTES).update(util.hexToBytes(serializableBody.toCbor())).digest())
    )
  };
};

export const createTransactionInternals = (props: CreateTxInternalsProps): Cardano.TxBodyWithHash => {
  const { txBody } = createPreInputSelectionTxBody({ ...props });
  return includeChangeAndInputs({ bodyPreInputSelection: txBody, inputSelection: props.inputSelection });
};
