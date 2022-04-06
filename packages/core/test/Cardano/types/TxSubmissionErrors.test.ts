import { Cardano } from '../../../src';
import { TxSubmission } from '@cardano-ogmios/client';
import { TxSubmissionErrors } from '../../../src/Cardano';

describe('Cardano/types/TxSuubmissionErrors', () => {
  test('TxSubmissionError can be narrowed down with "instanceof"', () => {
    const error: Cardano.TxSubmissionError = new Cardano.TxSubmissionErrors.FeeTooSmallError({
      feeTooSmall: { actualFee: 50n, requiredFee: 51n }
    });
    expect(error).toBeInstanceOf(Cardano.TxSubmissionErrors.FeeTooSmallError);
  });
  test('maps all errors from Ogmios', () => {
    const ogmiosErrors = Object.keys(TxSubmission.errors).sort();
    const sdkErrors = Object.keys(TxSubmissionErrors)
      .filter((e) => e !== 'UnknownTxSubmissionError')
      .map((e) => e.slice(0, Math.max(0, e.length - 5))) // drop 'Error' suffix
      .sort();
    expect(sdkErrors).toEqual(ogmiosErrors);
  });
});
