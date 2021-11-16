import { Cardano } from '@cardano-sdk/core';

export interface TxWithEpoch {
  tx: Cardano.TxAlonzo;
  epoch: Cardano.Epoch;
}
