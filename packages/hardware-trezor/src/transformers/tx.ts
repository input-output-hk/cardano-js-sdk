import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress } from '@cardano-sdk/key-management';
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
const trezorTxTransformer = async (
  body: Cardano.TxBody,
  context: TrezorTxTransformerContext
): Promise<Omit<Trezor.CardanoSignTransaction, 'signingMode'>> => {
  const inputs = await mapTxIns(body.inputs, context);
  return {
    additionalWitnessRequests: mapAdditionalWitnessRequests(inputs, context),
    auxiliaryData: body.auxiliaryDataHash ? mapAuxiliaryData(body.auxiliaryDataHash) : undefined,
    certificates: mapCerts(body.certificates ?? [], context),
    collateralInputs: body.collaterals ? await mapTxIns(body.collaterals, context) : undefined,
    collateralReturn: body.collateralReturn ? toTxOut(body.collateralReturn, context) : undefined,
    fee: body.fee.toString(),
    inputs,
    mint: mapTokenMap(body.mint, true),
    networkId: context.chainId.networkId,
    outputs: mapTxOuts(body.outputs, context),
    protocolMagic: context.chainId.networkMagic,
    referenceInputs: body.referenceInputs ? await mapTxIns(body.referenceInputs, context) : undefined,
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
  chainId,
  inputResolver,
  knownAddresses
}: {
  chainId: Cardano.ChainId;
  inputResolver: Cardano.InputResolver;
  knownAddresses: GroupedAddress[];
  cardanoTxBody: Cardano.TxBody;
}): Promise<Omit<Trezor.CardanoSignTransaction, 'signingMode'>> =>
  trezorTxTransformer(cardanoTxBody, {
    chainId,
    inputResolver,
    knownAddresses
  });
