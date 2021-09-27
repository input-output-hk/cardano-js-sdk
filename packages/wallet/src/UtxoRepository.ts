import Schema from '@cardano-ogmios/schema';
import { SelectionConstraints, SelectionResult } from '@cardano-sdk/cip2';
import { CSL } from '@cardano-sdk/core';

export interface UtxoRepository {
  allUtxos: Schema.Utxo;
  rewards: Schema.Lovelace;
  delegation: Schema.PoolId;
  sync: () => Promise<void>;
  selectInputs: (outputs: CSL.TransactionOutputs, constraints: SelectionConstraints) => Promise<SelectionResult>;
}
