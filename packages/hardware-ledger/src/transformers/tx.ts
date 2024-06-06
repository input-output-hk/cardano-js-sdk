import { mapAuxiliaryData } from './auxiliaryData.js';
import { mapCerts } from './certificates.js';
import { mapCollateralTxIns } from './collateralInputs.js';
import { mapCollateralTxOut } from './collateralOutput.js';
import { mapReferenceInputs } from './referenceInputs.js';
import { mapRequiredSigners } from './requiredSigners.js';
import { mapTokenMap } from './assets.js';
import { mapTxIns } from './txIn.js';
import { mapTxOuts } from './txOut.js';
import { mapVotingProcedures } from './votingProcedures.js';
import { mapWithdrawals } from './withdrawals.js';
import { transformObj } from '@cardano-sdk/util';
import type * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import type { Cardano } from '@cardano-sdk/core';
import type { LedgerTxTransformerContext } from '../types.js';
import type { Transformer } from '@cardano-sdk/util';

export const LedgerTxTransformer: Transformer<Cardano.TxBody, Ledger.Transaction, LedgerTxTransformerContext> = {
  auxiliaryData: ({ auxiliaryDataHash }) => mapAuxiliaryData(auxiliaryDataHash),
  certificates: async ({ certificates }, context) => await mapCerts(certificates, context!),
  collateralInputs: ({ collaterals }, context) => mapCollateralTxIns(collaterals, context!),
  collateralOutput: ({ collateralReturn }, context) => mapCollateralTxOut(collateralReturn, context!),
  donation: ({ donation }) => donation,
  fee: ({ fee }) => fee,
  includeNetworkId: ({ networkId }) => !!networkId,
  inputs: ({ inputs }, context) => mapTxIns(inputs, context!),
  mint: ({ mint }) => mapTokenMap(mint),
  network: (_, context) => ({
    networkId: context!.chainId.networkId,
    protocolMagic: context!.chainId.networkMagic
  }),
  outputs: ({ outputs }, context) => mapTxOuts(outputs, context!),
  referenceInputs: ({ referenceInputs }) => mapReferenceInputs(referenceInputs),
  requiredSigners: ({ requiredExtraSignatures }, context) => mapRequiredSigners(requiredExtraSignatures, context!),
  scriptDataHashHex: ({ scriptIntegrityHash }) => scriptIntegrityHash?.toString(),
  totalCollateral: ({ totalCollateral }) => totalCollateral,
  treasury: ({ treasuryValue }) => treasuryValue,
  ttl: ({ validityInterval }) => validityInterval?.invalidHereafter,
  validityIntervalStart: ({ validityInterval }) => validityInterval?.invalidBefore,
  votingProcedures: ({ votingProcedures }) => mapVotingProcedures(votingProcedures),
  withdrawals: ({ withdrawals }, context) => mapWithdrawals(withdrawals, context!)
};

export const toLedgerTx = (body: Cardano.TxBody, context: LedgerTxTransformerContext) =>
  transformObj(body, LedgerTxTransformer, context);
