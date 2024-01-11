import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';
import { TrezorTxTransformerContext } from '../types';
import { mapAdditionalWitnessRequests } from './additionalWitnessRequests';
import { mapAuxiliaryData, mapCerts, mapRequiredSigners, mapTxIns, mapTxOuts, mapWithdrawals, toTxOut } from './';
import { mapTokenMap } from './assets';

/**
 * Temporary transformer function that returns a partial
 * trezor.CardanoSignTransaction object which can be merged
 * into the extisting implementation (later we should refactor
 * this function to the Transformer interface like in the
 * hardware-ledger package)
 */
const trezorTxTransformer = (
  body: Cardano.TxBody,
  context: TrezorTxTransformerContext
): Omit<Trezor.CardanoSignTransaction, 'signingMode'> => {
  const inputs = mapTxIns(body.inputs, context);
  return {
    additionalWitnessRequests: mapAdditionalWitnessRequests(inputs, context),
    auxiliaryData: body.auxiliaryDataHash ? mapAuxiliaryData(body.auxiliaryDataHash) : undefined,
    certificates: mapCerts(body.certificates ?? [], context),
    collateralInputs: body.collaterals ? mapTxIns(body.collaterals, context) : undefined,
    collateralReturn: body.collateralReturn ? toTxOut(body.collateralReturn, context) : undefined,
    fee: body.fee.toString(),
    inputs,
    mint: mapTokenMap(body.mint, true),
    networkId: context.chainId.networkId,
    outputs: mapTxOuts(body.outputs, context),
    protocolMagic: context.chainId.networkMagic,
    referenceInputs: body.referenceInputs ? mapTxIns(body.referenceInputs, context) : undefined,
    requiredSigners: body.requiredExtraSignatures
      ? mapRequiredSigners(body.requiredExtraSignatures, context)
      : undefined,
    totalCollateral: body.totalCollateral ? body.totalCollateral.toString() : undefined,
    ttl: body.validityInterval?.invalidHereafter?.toString(),
    validityIntervalStart: body.validityInterval?.invalidBefore?.toString(),
    withdrawals: mapWithdrawals(body.withdrawals ?? [], context)
  };
};

/** Takes a core transaction and context data necessary to transform it into a trezor.CardanoSignTransaction */
export const txToTrezor = ({
  cardanoTxBody,
  ...context
}: {
  cardanoTxBody: Cardano.TxBody;
} & TrezorTxTransformerContext): Omit<Trezor.CardanoSignTransaction, 'signingMode'> =>
  trezorTxTransformer(cardanoTxBody, context);
