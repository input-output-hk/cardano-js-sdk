import { Cardano } from '@cardano-sdk/core';

export interface OutputValidation {
  minimumCoin: Cardano.Lovelace;
  coinMissing: Cardano.Lovelace;
  tokenBundleSizeExceedsLimit: boolean;
}

export type MinimumCoinQuantityPerOutput = Map<Cardano.TxOut, OutputValidation>;
