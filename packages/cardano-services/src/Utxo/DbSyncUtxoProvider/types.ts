/* eslint-disable @typescript-eslint/no-explicit-any */
/*
 * There will be as many rows as tokens are in Value object
 */
export interface UtxoModel {
  address: string;
  coins: string;
  index: number;
  tx_id: string;
  asset_quantity?: string;
  asset_name?: string;
  asset_policy?: string;
  data_hash?: string;
  inline_datum?: string;
  reference_script_type?: string;
  /** CBOR encoded plutus script data, null for other script types */
  reference_script_bytes?: string;
  /** JSON representation of the timelock and multisig script, null for other script types */
  reference_script_json?: any;
}

/**
 * Currently supported reference scripts types according to dbSync:
 *
 * https://github.com/input-output-hk/cardano-db-sync/blob/master/cardano-db/src/Cardano/Db/Types.hs#L258-L264
 */
export enum ReferenceScriptType {
  Multisig = 'multisig',
  Timelock = 'timelock',
  PlutusV1 = 'plutusV1',
  PlutusV2 = 'plutusV2',
  PlutusV3 = 'plutusV3'
}
