import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';
import { Transformer, transformObj } from '@cardano-sdk/util';
import { TrezorTxTransformerContext } from '../types';
import { mapAdditionalWitnessRequests } from './additionalWitnessRequests';
import { mapAuxiliaryData, mapCerts, mapRequiredSigners, mapTxIns, mapTxOuts, mapWithdrawals, toTxOut } from './';
import { mapTokenMap } from './assets';

export const trezorTxTransformer: Transformer<
  Cardano.TxBody,
  Omit<Trezor.CardanoSignTransaction, 'signingMode' | 'derivationType' | 'includeNetworkId'>,
  TrezorTxTransformerContext
> = {
  additionalWitnessRequests: ({ inputs }, context) => mapAdditionalWitnessRequests(inputs, context!),
  auxiliaryData: ({ auxiliaryDataHash }) => (auxiliaryDataHash ? mapAuxiliaryData(auxiliaryDataHash) : undefined),
  certificates: ({ certificates }, context) => (certificates ? mapCerts(certificates, context!) : undefined),
  collateralInputs: ({ collaterals }, context) => (collaterals ? mapTxIns(collaterals, context!) : undefined),
  collateralReturn: ({ collateralReturn }, context) =>
    collateralReturn ? toTxOut(collateralReturn, context!) : undefined,
  fee: ({ fee }) => fee.toString(),
  inputs: ({ inputs }, context) => mapTxIns(inputs, context!),
  mint: ({ mint }) => mapTokenMap(mint, true),
  networkId: (_, context) => context!.chainId.networkId,
  outputs: ({ outputs }, context) => mapTxOuts(outputs, context!),
  protocolMagic: (_, context) => context!.chainId.networkMagic,
  referenceInputs: ({ referenceInputs }, context) =>
    referenceInputs ? mapTxIns(referenceInputs, context!) : undefined,
  requiredSigners: ({ requiredExtraSignatures }, context) =>
    requiredExtraSignatures ? mapRequiredSigners(requiredExtraSignatures, context!) : undefined,
  scriptDataHash: ({ scriptIntegrityHash }) => scriptIntegrityHash?.toString(),
  totalCollateral: ({ totalCollateral }) => totalCollateral?.toString(),
  ttl: ({ validityInterval }) => validityInterval?.invalidHereafter?.toString(),
  validityIntervalStart: ({ validityInterval }) => validityInterval?.invalidBefore?.toString(),
  withdrawals: ({ withdrawals }, context) => mapWithdrawals(withdrawals, context!)
};

export const txToTrezor = (body: Cardano.TxBody, context: TrezorTxTransformerContext) =>
  transformObj(body, trezorTxTransformer, context);
