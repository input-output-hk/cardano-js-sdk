import Schema from '@cardano-ogmios/schema';
import { SelectionConstraints, SelectionResult } from '@cardano-sdk/cip2';
import { CSL } from '@cardano-sdk/core';

export interface UtxoRepository {
  allUtxos: Schema.Utxo;
  rewards: Schema.Lovelace | null;
  delegation: Schema.PoolId | null;
  sync: () => Promise<void>;
  selectInputs: (outputs: Set<CSL.TransactionOutput>, constraints: SelectionConstraints) => Promise<SelectionResult>;
}
