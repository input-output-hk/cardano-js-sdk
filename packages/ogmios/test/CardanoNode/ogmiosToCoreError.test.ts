import {
  Cardano,
  ChainSyncError,
  ChainSyncErrorCode,
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  IncompleteWithdrawalsData,
  OutsideOfValidityIntervalData,
  StateQueryError,
  StateQueryErrorCode,
  TxSubmissionError,
  TxSubmissionErrorCode,
  UnknownOutputReferencesData,
  ValueNotConservedData
} from '@cardano-sdk/core';
import {
  SubmitTransactionFailureIncompleteWithdrawals,
  SubmitTransactionFailureOutsideOfValidityInterval,
  SubmitTransactionFailureUnknownOutputReferences,
  SubmitTransactionFailureValueNotConserved
} from '@cardano-ogmios/schema';
import { ogmiosToCoreError } from '../../src/CardanoNode/queries';

describe('queries', () => {
  describe('ogmiosToCoreError', () => {
    const message = 'Test error';
    it.each([null, 'stringish'])('maps %s error to GeneralCardanoNodeErrorCode.Unknown', (error) => {
      const result = ogmiosToCoreError(error);
      expect(result).toBeInstanceOf(GeneralCardanoNodeError);
      expect(result.code).toEqual(GeneralCardanoNodeErrorCode.Unknown);
      expect(result.data).toEqual(error);
    });

    it('maps a GeneralCardanoNodeError', () => {
      const error = { code: GeneralCardanoNodeErrorCode.Unknown, message };
      const result = ogmiosToCoreError(error);
      expect(result).toBeInstanceOf(GeneralCardanoNodeError);
      expect(result.code).toEqual(GeneralCardanoNodeErrorCode.Unknown);
      expect(result.message).toEqual(error.message);
      // in the absence of data property, the whole error is mapped as data
      expect(result.data).toEqual(error);
    });

    it('maps a StateQueryError', () => {
      const error = {
        code: StateQueryErrorCode.AcquireLedgerStateFailure,
        data: { prop: 'testProp' },
        message
      };
      const result = ogmiosToCoreError(error);
      expect(result).toBeInstanceOf(StateQueryError);
      expect(result.code).toEqual(StateQueryErrorCode.AcquireLedgerStateFailure);
      expect(result.data).toEqual(error.data);
    });

    it('maps a chain sync error', () => {
      const error = { code: ChainSyncErrorCode.IntersectionInterleaved, data: { prop: 'testProp' }, message };
      const result = ogmiosToCoreError(error);
      expect(result).toBeInstanceOf(ChainSyncError);
      expect(result.code).toEqual(ChainSyncErrorCode.IntersectionInterleaved);
      expect(result.data).toEqual(error.data);
    });

    it('maps a connection error', () => {
      const error = { code: 'ECONNREFUSED', message };
      const result = ogmiosToCoreError(error);
      expect(result).toBeInstanceOf(GeneralCardanoNodeError);
      expect(result.code).toEqual(GeneralCardanoNodeErrorCode.ConnectionFailure);
      expect(result.data).toEqual(error);
    });

    it('maps an unknown error when error code is not recognized', () => {
      const error = { code: 9999, message };
      const result = ogmiosToCoreError(error);
      expect(result).toBeInstanceOf(GeneralCardanoNodeError);
      expect(result.code).toEqual(GeneralCardanoNodeErrorCode.Unknown);
      expect(result.data).toEqual(error);
    });

    it('maps to an unknown error when code is not a number and data is not a connection error', () => {
      const error = { code: 'invalidCode', message };
      const result = ogmiosToCoreError(error);
      expect(result).toBeInstanceOf(GeneralCardanoNodeError);
      expect(result.code).toEqual(GeneralCardanoNodeErrorCode.Unknown);
      expect(result.data).toEqual(error);
    });

    describe('TxSubmissionError', () => {
      const stakeAddress1 = Cardano.RewardAccount('stake1uyehkck0lajq8gr28t9uxnuvgcqrc6070x3k9r8048z8y5gh6ffgw');
      const stakeAddress2 = Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');

      const txId1 = Cardano.TransactionId('295d5e0f7ee182426eaeda8c9f1c63502c72cdf4afd6e0ee0f209adf94a614e7');
      const txId2 = Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819');

      it('maps data to a ValueNotConserved error', () => {
        const error: SubmitTransactionFailureValueNotConserved = {
          code: TxSubmissionErrorCode.ValueNotConserved,
          data: {
            valueConsumed: { ada: { lovelace: 100n } },
            valueProduced: { ada: { lovelace: 200n } }
          },
          message
        };
        const result = ogmiosToCoreError(error);
        expect(result).toBeInstanceOf(TxSubmissionError);
        expect(result.code).toEqual(TxSubmissionErrorCode.ValueNotConserved);
        expect(result.data).toEqual({
          consumed: { assets: new Map(), coins: 100n },
          produced: { assets: new Map(), coins: 200n }
        } as ValueNotConservedData);
      });

      it('maps data to an IncompleteWithdrawals error', () => {
        const error: SubmitTransactionFailureIncompleteWithdrawals = {
          code: TxSubmissionErrorCode.IncompleteWithdrawals,
          data: {
            incompleteWithdrawals: {
              [stakeAddress1]: { ada: { lovelace: 100n } },
              [stakeAddress2]: { ada: { lovelace: 200n } }
            }
          },
          message
        };
        const result = ogmiosToCoreError(error);
        expect(result).toBeInstanceOf(TxSubmissionError);
        expect(result.code).toEqual(TxSubmissionErrorCode.IncompleteWithdrawals);
        expect(result.data).toEqual({
          withdrawals: [
            { quantity: 100n, stakeAddress: stakeAddress1 },
            { quantity: 200n, stakeAddress: stakeAddress2 }
          ]
        } as IncompleteWithdrawalsData);
      });

      it('maps data to an OutsideOfValidityInterval error', () => {
        const error: SubmitTransactionFailureOutsideOfValidityInterval = {
          code: TxSubmissionErrorCode.OutsideOfValidityInterval,
          data: {
            currentSlot: 100,
            validityInterval: {
              invalidAfter: 150,
              invalidBefore: 50
            }
          },
          message
        };
        const result = ogmiosToCoreError(error);
        expect(result).toBeInstanceOf(TxSubmissionError);
        expect(result.code).toEqual(TxSubmissionErrorCode.OutsideOfValidityInterval);
        expect(result.data).toEqual({
          currentSlot: 100,
          validityInterval: {
            invalidBefore: 50,
            invalidHereafter: 150
          }
        } as OutsideOfValidityIntervalData);
      });

      it('maps data to an UnknownOutputReferences error', () => {
        const error: SubmitTransactionFailureUnknownOutputReferences = {
          code: TxSubmissionErrorCode.UnknownOutputReferences,
          data: {
            unknownOutputReferences: [
              { index: 1, transaction: { id: txId1 } },
              { index: 2, transaction: { id: txId2 } }
            ]
          },
          message
        };
        const result = ogmiosToCoreError(error);
        expect(result).toBeInstanceOf(TxSubmissionError);
        expect(result.code).toEqual(TxSubmissionErrorCode.UnknownOutputReferences);
        expect(result.data).toEqual({
          unknownOutputReferences: [
            { index: 1, txId: txId1 },
            { index: 2, txId: txId2 }
          ]
        } as UnknownOutputReferencesData);
      });

      it('returns data as is in all other cases', () => {
        const error = {
          code: 3116,
          data: { prop: 'testProp' },
          message
        };
        const result = ogmiosToCoreError(error);
        expect(result).toBeInstanceOf(TxSubmissionError);
        expect(result.code).toEqual(error.code);
        expect(result.data).toEqual(error.data);
      });
    });
  });
});
