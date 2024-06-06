import * as CardanoNodeUtil from '../../src/CardanoNode/errorUtils.js';
import { CardanoNodeErrors } from '@cardano-sdk/core';

const unavailableQueryError = new CardanoNodeErrors.CardanoClientErrors.QueryUnavailableInCurrentEraError(
  'currentEpoch'
);
const unknownResultError = new CardanoNodeErrors.CardanoClientErrors.UnknownResultError('result');
const someOtherError = new Error('some other error');
const someString = 'some string';

describe('cardanoNodeErros', () => {
  describe('isCardanoNodeError', () => {
    it('is true if the value is a cardano node error', () => {
      expect(CardanoNodeUtil.isCardanoNodeError(unavailableQueryError)).toBe(true);
    });
    it('is false if a single generic error is not a cardano node error', () => {
      expect(CardanoNodeUtil.isCardanoNodeError(someOtherError)).toBe(false);
    });
    it('is false if a non-error value is passed', () => {
      expect(CardanoNodeUtil.isCardanoNodeError(someString)).toBe(false);
    });
  });

  describe('asCardanoNodeError', () => {
    it('returns the same error if it is a cardano node error', () => {
      expect(CardanoNodeUtil.asCardanoNodeError(unavailableQueryError)).toBe<CardanoNodeErrors.CardanoNodeError>(
        unavailableQueryError
      );
    });

    it('returns null if error is not a cardano node error', () => {
      expect(CardanoNodeUtil.asCardanoNodeError(someOtherError)).toBeNull();
    });
    it('returns null if a non-error value is passed', () => {
      expect(CardanoNodeUtil.asCardanoNodeError(someString)).toBeNull();
    });

    it('returns the first error if all values in an array are cardano node errors', () => {
      expect(
        CardanoNodeUtil.asCardanoNodeError([unavailableQueryError, unknownResultError])
      ).toBe<CardanoNodeErrors.CardanoNodeError>(unavailableQueryError);
    });

    it('returns the first cardano node error if at least one value in an array is a cardano node error', () => {
      expect(
        CardanoNodeUtil.asCardanoNodeError([someOtherError, unknownResultError])
      ).toBe<CardanoNodeErrors.CardanoNodeError>(unknownResultError);
    });

    it('returns null if none of the values in an array are cardano node errors', () => {
      expect(CardanoNodeUtil.asCardanoNodeError([someOtherError, someString])).toBeNull();
    });
  });
});
