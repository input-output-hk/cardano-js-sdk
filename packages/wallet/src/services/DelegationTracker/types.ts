import { Cardano } from '@cardano-sdk/core';

export interface TxWithEpoch {
  tx: Cardano.HydratedTx<Cardano.HydratedTxBodyPostConway>;
  epoch: Cardano.EpochNo;
}
