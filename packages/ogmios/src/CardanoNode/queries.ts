import {
  Cardano,
  CardanoNodeUtil,
  ChainSyncError,
  CredentialAlreadyRegisteredData,
  DRepAlreadyRegisteredData,
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  IncompleteWithdrawalsData,
  OutsideOfValidityIntervalData,
  StakeDistribution,
  StateQueryError,
  TxSubmissionError,
  TxSubmissionErrorCode,
  UnknownOutputReferencesData,
  ValueNotConservedData
} from '@cardano-sdk/core';

import { LedgerStateQuery } from '@cardano-ogmios/client';
import { Logger } from 'ts-log';
import {
  SubmitTransactionFailureCredentialAlreadyRegistered,
  SubmitTransactionFailureDRepAlreadyRegistered,
  SubmitTransactionFailureIncompleteWithdrawals,
  SubmitTransactionFailureOutsideOfValidityInterval,
  SubmitTransactionFailureUnknownOutputReferences,
  SubmitTransactionFailureValueNotConserved
} from '@cardano-ogmios/schema';
import { eraSummary, genesis } from '../ogmiosToCore';
import { isConnectionError } from '@cardano-sdk/util';
import { mapTxIn, mapValue, mapWithdrawals } from '../ogmiosToCore/tx';
import type * as Crypto from '@cardano-sdk/crypto';

const errorDataToCore = (data: unknown, code: number) => {
  switch (code) {
    case TxSubmissionErrorCode.ValueNotConserved: {
      const typedData = data as SubmitTransactionFailureValueNotConserved['data'];
      return {
        consumed: mapValue(typedData.valueConsumed),
        produced: mapValue(typedData.valueProduced)
      } as ValueNotConservedData;
    }
    case TxSubmissionErrorCode.IncompleteWithdrawals: {
      const typedData = data as SubmitTransactionFailureIncompleteWithdrawals['data'];
      return {
        withdrawals: mapWithdrawals(typedData.incompleteWithdrawals)
      } as IncompleteWithdrawalsData;
    }
    case TxSubmissionErrorCode.OutsideOfValidityInterval: {
      const typedData = data as SubmitTransactionFailureOutsideOfValidityInterval['data'];
      return {
        currentSlot: typedData.currentSlot,
        validityInterval: {
          invalidBefore: typedData.validityInterval.invalidBefore,
          invalidHereafter: typedData.validityInterval.invalidAfter
        }
      } as OutsideOfValidityIntervalData;
    }
    case TxSubmissionErrorCode.UnknownOutputReferences: {
      const typedData = data as SubmitTransactionFailureUnknownOutputReferences['data'];
      return {
        unknownOutputReferences: typedData.unknownOutputReferences.map(mapTxIn)
      } as UnknownOutputReferencesData;
    }
    case TxSubmissionErrorCode.CredentialAlreadyRegistered: {
      const typedData = data as SubmitTransactionFailureCredentialAlreadyRegistered['data'];

      return {
        hash: typedData.knownCredential as Crypto.Hash28ByteBase16
      } as CredentialAlreadyRegisteredData;
    }
    case TxSubmissionErrorCode.DRepAlreadyRegistered: {
      const typedData = data as SubmitTransactionFailureDRepAlreadyRegistered['data'];

      if (typedData.knownDelegateRepresentative.type === 'registered') {
        return {
          hash: typedData.knownDelegateRepresentative.id as Crypto.Hash28ByteBase16
        } as DRepAlreadyRegisteredData;
      }
      return null;
    }
    default:
      // Mapper not implemented
      return data;
  }
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const ogmiosToCoreError = (error: any) => {
  if (typeof error === 'object' && error !== null) {
    if (typeof error.code === 'number') {
      const { code, message } = error;
      const data = error.data || error;
      if (CardanoNodeUtil.isGeneralCardanoNodeErrorCode(code)) {
        return new GeneralCardanoNodeError(code, data, message);
      } else if (CardanoNodeUtil.isStateQueryErrorCode(code)) {
        return new StateQueryError(code, data, message);
      } else if (CardanoNodeUtil.isTxSubmissionErrorCode(code)) {
        return new TxSubmissionError(code, errorDataToCore(data, code), message);
      } else if (CardanoNodeUtil.isChainSyncErrorCode(code)) {
        return new ChainSyncError(code, data, message);
      }
    } else if (isConnectionError(error)) {
      return new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.ConnectionFailure, error, 'Connection failure');
    }
  }
  return new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.Unknown, error, 'Unknown error, see "data"');
};

export const withCoreCardanoNodeError = async <T>(operation: () => Promise<T>) => {
  try {
    return await operation();
  } catch (error) {
    throw ogmiosToCoreError(error);
  }
};

export const queryEraSummaries = (client: LedgerStateQuery.LedgerStateQueryClient, logger: Logger) =>
  withCoreCardanoNodeError(async () => {
    logger.info('Querying era summaries');
    const systemStart = new Date((await client.genesisConfiguration('byron')).startTime);
    const eraSummaries = await client.eraSummaries();
    return eraSummaries.map((era) => eraSummary(era, systemStart));
  });

export const queryGenesisParameters = (client: LedgerStateQuery.LedgerStateQueryClient, logger: Logger) =>
  withCoreCardanoNodeError(async () => {
    logger.info('Querying genesis parameters');
    // Update this to query multiple eras if the CompactGenesis type will have to include params from other eras
    return genesis(await client.genesisConfiguration('shelley'));
  });

export const queryStakeDistribution = (client: LedgerStateQuery.LedgerStateQueryClient, logger: Logger) =>
  withCoreCardanoNodeError(async () => {
    logger.info('Querying stake distribution');
    const map: StakeDistribution = new Map();
    for (const [key, value] of Object.entries(await client.liveStakeDistribution())) {
      const splitStake = value.stake.split('/');
      map.set(Cardano.PoolId(key), {
        stake: { pool: BigInt(splitStake[0]), supply: BigInt(splitStake[1]) },
        vrf: Cardano.VrfVkHex(value.vrf)
      });
    }
    return map;
  });
