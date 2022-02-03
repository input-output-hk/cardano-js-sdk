import { Cardano } from '../../../src';

describe('Cardano/types/TxSuubmissionErrors', () => {
  test('TxSubmissionError can be narrowed down with "instanceof"', () => {
    const error: Cardano.TxSubmissionError = new Cardano.TxSubmissionErrors.FeeTooSmallError({
      feeTooSmall: { actualFee: 50n, requiredFee: 51n }
    });
    expect(error).toBeInstanceOf(Cardano.TxSubmissionErrors.FeeTooSmallError);
  });
});
