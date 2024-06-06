import { CardanoNodeErrors } from '../../../src/index.js';
import { TxSubmission } from '@cardano-ogmios/client';

describe('Cardano/types/TxSubmissionErrors', () => {
  test('TxSubmissionError can be narrowed down with "instanceof"', () => {
    const error: CardanoNodeErrors.TxSubmissionError = new CardanoNodeErrors.TxSubmissionErrors.FeeTooSmallError({
      feeTooSmall: { actualFee: 50n, requiredFee: 51n }
    });
    expect(error).toBeInstanceOf(CardanoNodeErrors.TxSubmissionErrors.FeeTooSmallError);
  });
  test('maps all errors from Ogmios', () => {
    const ogmiosErrors = Object.keys(TxSubmission.submissionErrors.errors).sort();
    const sdkErrors = Object.keys(CardanoNodeErrors.TxSubmissionErrors)
      .filter((e) => e !== 'UnknownTxSubmissionError')
      .map((e) => e.slice(0, Math.max(0, e.length - 5))) // drop 'Error' suffix
      .sort();
    expect(sdkErrors).toEqual(ogmiosErrors);
  });
});
