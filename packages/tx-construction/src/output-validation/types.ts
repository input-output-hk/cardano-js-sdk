import { Cardano } from '@cardano-sdk/core';

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
   * @returns Validates that token bundle size is within limits and computes minimum coin quantity
   */
  validateOutput(output: Cardano.TxOut): Promise<OutputValidation>;
  /**
   * @returns For every output, validates that token bundle size is within limits and computes minimum coin quantity
   */
  validateOutputs(outputs: Iterable<Cardano.TxOut>): Promise<Map<Cardano.TxOut, OutputValidation>>;
}

export type MinimumCoinQuantityPerOutput = Map<Cardano.TxOut, OutputValidation>;
