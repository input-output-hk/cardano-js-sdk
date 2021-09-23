import Schema from '@cardano-ogmios/schema';
import { SelectionConstraints, SelectionResult } from '@cardano-sdk/cip2';
import CardanoSerializationLib from '@emurgo/cardano-serialization-lib-nodejs';

export interface UtxoRepository {
  allUtxos: Schema.Utxo;
  rewards: Schema.Lovelace;
  delegation: Schema.PoolId;
  sync: () => Promise<void>;
  selectInputs: (
    outputs: CardanoSerializationLib.TransactionOutputs,
    constraints: SelectionConstraints
  ) => Promise<SelectionResult>;
}
