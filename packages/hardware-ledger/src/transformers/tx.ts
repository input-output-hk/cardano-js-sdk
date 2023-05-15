import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../types';
import { Transformer, transformObj } from '@cardano-sdk/util';
import { mapAuxiliaryData } from './auxiliaryData';
import { mapCerts } from './certificates';
import { mapCollateralTxIns } from './collateralInputs';
import { mapCollateralTxOut } from './collateralOutput';
import { mapReferenceInputs } from './referenceInputs';
import { mapRequiredSigners } from './requiredSigners';
import { mapTokenMap } from './assets';
import { mapTxIns } from './txIn';
import { mapTxOuts } from './txOut';
import { mapWithdrawals } from './withdrawals';

export const LedgerTxTransformer: Transformer<Cardano.TxBody, Ledger.Transaction, LedgerTxTransformerContext> = {
  auxiliaryData: ({ auxiliaryDataHash }) => mapAuxiliaryData(auxiliaryDataHash),
  certificates: ({ certificates }, context) => mapCerts(certificates, context!),
  collateralInputs: async ({ collaterals }, context) => mapCollateralTxIns(collaterals, context!),
  collateralOutput: ({ collateralReturn }, context) => mapCollateralTxOut(collateralReturn, context!),
  fee: ({ fee }) => fee,
  includeNetworkId: ({ networkId }) => !!networkId,
  inputs: async ({ inputs }, context) => await mapTxIns(inputs, context!),
  mint: ({ mint }) => mapTokenMap(mint),
  network: (_, context) => ({
    networkId: context!.chainId.networkId,
    protocolMagic: context!.chainId.networkMagic
  }),
  outputs: async ({ outputs }, context) => mapTxOuts(outputs, context!),
  referenceInputs: async ({ referenceInputs }) => mapReferenceInputs(referenceInputs),
  requiredSigners: ({ requiredExtraSignatures }, context) => mapRequiredSigners(requiredExtraSignatures, context!),
  scriptDataHashHex: ({ scriptIntegrityHash }) => scriptIntegrityHash?.toString(),
  totalCollateral: ({ totalCollateral }) => totalCollateral,
  ttl: ({ validityInterval }) => validityInterval?.invalidHereafter,
  validityIntervalStart: ({ validityInterval }) => validityInterval?.invalidBefore,
  withdrawals: ({ withdrawals }, context) => mapWithdrawals(withdrawals, context!)
};

export const toLedgerTx = (body: Cardano.TxBody, context: LedgerTxTransformerContext) =>
  transformObj(body, LedgerTxTransformer, context);
