import { Cardano } from '../../src';

describe('Cardano', () => {
  test('TxSubmissionError can be narrowed down with "instanceof"', () => {
    const error: Cardano.TxSubmissionError = new Cardano.TxSubmissionErrors.FeeTooSmallError({
      feeTooSmall: { actualFee: 50, requiredFee: 51 }
    });
    expect(error).toBeInstanceOf(Cardano.TxSubmissionErrors.FeeTooSmallError);
  });
});
