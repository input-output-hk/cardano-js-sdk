import type { Cardano } from '@cardano-sdk/core';

export interface TxWithEpoch {
  tx: Cardano.HydratedTx;
  epoch: Cardano.EpochNo;
}
