import { Cardano, createUtxoId } from '@cardano-sdk/core';
import { UtxoModel } from './types';
import { generateAssetId } from './util';
import { isNotNil } from '@cardano-sdk/util';

/**
 * Parse the reference script from the UtxoModel
 *
 * @param model The UtxoModel from dbSync.
 * @returns The reference Script.
 */
const parseReferenceScript = (model: UtxoModel): Cardano.Script => {
  let script: Cardano.Script;
  switch (model.reference_script_type) {
    case ReferenceScriptType.Timelock:
    case ReferenceScriptType.Multisig:
      if (!isNotNil(model.reference_script_json))
        throw new SerializationError(
          SerializationFailure.InvalidScript,
          'Unexpected error deserializing Native script. Data is null'
        );
      script = jsonToNativeScript(model.reference_script_json);
      break;
    case ReferenceScriptType.PlutusV1:
      if (!isNotNil(model.reference_script_bytes))
        throw new SerializationError(
          SerializationFailure.InvalidScript,
          'Unexpected error deserializing PlutusV1 script. Data is null'
        );
      script = {
        __type: Cardano.ScriptType.Plutus,
        bytes: Cardano.util.HexBlob(model.reference_script_bytes),
        version: Cardano.PlutusLanguageVersion.V1
      };
      break;
    case ReferenceScriptType.PlutusV2:
      if (!isNotNil(model.reference_script_bytes))
        throw new SerializationError(
          SerializationFailure.InvalidScript,
          'Unexpected error deserializing PlutusV2 script. Data is null'
        );
      script = {
        __type: Cardano.ScriptType.Plutus,
        bytes: Cardano.util.HexBlob(model.reference_script_bytes),
        version: Cardano.PlutusLanguageVersion.V2
      };
      break;
    default:
      throw new SerializationError(
        SerializationFailure.InvalidScriptType,
        `Unknown script type ${model.reference_script_type}`
      );
  }
  return script;
};

/**
 * Transform DB results into indexed core UTxO
 *
 * @param {UtxoModel[]} utxosModels  UTxO query rows
 * @returns {Cardano.Utxo[]} an array of core UTxO objects
 */
export const utxosToCore = (utxosModels: UtxoModel[]): Cardano.Utxo[] => {
  const utxosMap = utxosModels.reduce((utxos, current) => {
    const utxoId = createUtxoId(current.tx_id, current.index);
    const utxo = utxos.get(utxoId);
    if (utxo) {
      const txIn = utxo[0];
      const txOut = utxo[1];
      if (isNotNil(current.asset_name) && current.asset_policy && current.asset_quantity) {
        const newAssets = txOut.value.assets || new Map<Cardano.AssetId, bigint>();
        newAssets.set(generateAssetId(current.asset_policy, current.asset_name), BigInt(current.asset_quantity));
        txOut.value.assets = newAssets;
      }
      utxos.set(utxoId, [txIn, txOut]);
    } else {
      const address = Cardano.Address(current.address);
      const txOut: Cardano.TxOut = {
        address,
        value: {
          coins: BigInt(current.coins)
        }
      };
      if (isNotNil(current.data_hash)) txOut.datumHash = Cardano.util.Hash32ByteBase16(current.data_hash);
      if (isNotNil(current.inline_datum)) txOut.datum = Cardano.util.HexBlob(current.inline_datum);
      if (isNotNil(current.reference_script_type)) txOut.scriptReference = parseReferenceScript(current);

      if (isNotNil(current.asset_name) && current.asset_policy && current.asset_quantity) {
        txOut.value.assets = new Map<Cardano.AssetId, bigint>([
          [generateAssetId(current.asset_policy, current.asset_name), BigInt(current.asset_quantity)]
        ]);
      }
      utxos.set(utxoId, [
        {
          address,
          index: current.index,
          txId: Cardano.TransactionId(current.tx_id)
        },
        txOut
      ]);
    }
    return utxos;
  }, new Map<string, Cardano.Utxo>());
  return [...utxosMap.values()];
};
