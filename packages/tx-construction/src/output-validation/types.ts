import type { Cardano } from '@cardano-sdk/core';

export type ProtocolParametersRequiredByOutputValidator = Pick<
  Cardano.ProtocolParameters,
  'coinsPerUtxoByte' | 'maxValueSize'
>;
export interface OutputValidatorContext {
  /** Queried on every OutputValidator call */
  protocolParameters: () => Promise<ProtocolParametersRequiredByOutputValidator>;
}

export interface OutputValidation {
  minimumCoin: Cardano.Lovelace;
  coinMissing: Cardano.Lovelace;
  tokenBundleSizeExceedsLimit: boolean;
  negativeAssetQty: boolean;
}

export interface OutputValidator {
  /**
   * Assumes that value will be used with an output that has:
   * - no datum
   * - grouped address (Shelley era+)
   *
   * @returns Validates that token bundle size is within limits and computes minimum coin quantity
   */
  validateValue(output: Cardano.Value): Promise<OutputValidation>;
  /**
   * Assumes that values will be used with outputs that have:
   * - no datum
   * - grouped address (Shelley era+)
   *
   * @returns For every value, validates that token bundle size is within limits and computes minimum coin quantity
   */
  validateValues(outputs: Iterable<Cardano.Value>): Promise<Map<Cardano.Value, OutputValidation>>;
  /**
   * @returns Validates that token bundle size is within limits and computes minimum coin quantity
   */
  validateOutput(output: Cardano.TxOut): Promise<OutputValidation>;
  /**
   * @returns For every output, validates that token bundle size is within limits and computes minimum coin quantity
   */
  validateOutputs(outputs: Iterable<Cardano.TxOut>): Promise<Map<Cardano.TxOut, OutputValidation>>;
}

export type MinimumCoinQuantityPerOutput = Map<Cardano.TxOut, OutputValidation>;
