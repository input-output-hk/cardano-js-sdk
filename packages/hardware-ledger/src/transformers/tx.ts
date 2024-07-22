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
import { mapVotingProcedures } from './votingProcedures';
import { mapWithdrawals } from './withdrawals';

export const LedgerTxTransformer: Transformer<Cardano.TxBody, Ledger.Transaction, LedgerTxTransformerContext> = {
  auxiliaryData: ({ auxiliaryDataHash }) => mapAuxiliaryData(auxiliaryDataHash),
  certificates: ({ certificates }, context) => mapCerts(certificates, context!),
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
  votingProcedures: ({ votingProcedures }, context) => mapVotingProcedures(votingProcedures, context!),
  withdrawals: ({ withdrawals }, context) => mapWithdrawals(withdrawals, context!)
};

export const toLedgerTx = (body: Cardano.TxBody, context: LedgerTxTransformerContext) =>
  transformObj(body, LedgerTxTransformer, context);
