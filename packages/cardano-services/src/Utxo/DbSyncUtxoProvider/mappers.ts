import {
  Cardano,
  Serialization,
  SerializationError,
  SerializationFailure,
  createUtxoId,
  jsonToNativeScript
} from '@cardano-sdk/core';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob, isNotNil } from '@cardano-sdk/util';
import { ReferenceScriptType, UtxoModel } from './types';
import { generateAssetId } from './util';

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
        bytes: model.reference_script_bytes as unknown as HexBlob,
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
        bytes: model.reference_script_bytes as unknown as HexBlob,
        version: Cardano.PlutusLanguageVersion.V2
      };
      break;
    case ReferenceScriptType.PlutusV3:
      if (!isNotNil(model.reference_script_bytes))
        throw new SerializationError(
          SerializationFailure.InvalidScript,
          'Unexpected error deserializing PlutusV2 script. Data is null'
        );
      script = {
        __type: Cardano.ScriptType.Plutus,
        bytes: model.reference_script_bytes as unknown as HexBlob,
        version: Cardano.PlutusLanguageVersion.V3
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
  // eslint-disable-next-line complexity
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
      const address = current.address as unknown as Cardano.PaymentAddress;
      const txOut: Cardano.TxOut = {
        address,
        value: {
          coins: BigInt(current.coins)
        }
      };
      if (isNotNil(current.inline_datum)) {
        txOut.datum = Serialization.PlutusData.fromCbor(HexBlob(current.inline_datum)).toCore();
      } else if (isNotNil(current.data_hash)) {
        txOut.datumHash = current.data_hash as unknown as Hash32ByteBase16;
      }
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
          txId: current.tx_id as unknown as Cardano.TransactionId
        },
        txOut
      ]);
    }
    return utxos;
  }, new Map<string, Cardano.Utxo>());
  return [...utxosMap.values()];
};
