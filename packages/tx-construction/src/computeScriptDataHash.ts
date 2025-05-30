/* eslint-disable unicorn/number-literal-case */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';

const CBOR_EMPTY_MAP = new Uint8Array([0xa0]);

/**
 * Encodes an array of CBOR-encodable objects into a CBOR format.
 *
 * Each object in the array is converted to its CBOR representation and then written into a
 * CBOR array.
 *
 * @param items An array of objects that can be encoded into CBOR.
 * @returns A `Uint8Array` containing the CBOR-encoded objects.
 */
const getCborEncodedArray = <T extends { toCbor: () => HexBlob }>(items: T[]): Uint8Array => {
  const writer = new Serialization.CborWriter();

  writer.writeStartArray(items.length);

  for (const item of items) {
    writer.writeEncodedValue(Buffer.from(item.toCbor(), 'hex'));
  }

  return writer.encode();
};

/**
 * Computes the hash of script data in a transaction, including redeemers, datums, and cost models.
 *
 * This function takes arrays of redeemers and datums, along with cost models, and encodes
 * them in a CBOR (Concise Binary Object Representation) format. The encoded data is then
 * hashed using the Blake2b hashing algorithm to produce a 32-byte hash. This hash is
 * representative of the script data in a transaction on the Cardano blockchain.
 *
 * @param costModels The cost models for script execution.
 * @param redemeers The redeemers in the transaction. If not present or empty, the function may return undefined.
 * @param datums The datums in the transaction.
 * @returns The hashed script data, or undefined if no redeemers are provided.
 */
const hashScriptData = (
  costModels: Serialization.Costmdls,
  redemeers?: Serialization.Redeemer[],
  datums?: Serialization.PlutusData[]
): Crypto.Hash32ByteBase16 | undefined => {
  const writer = new Serialization.CborWriter();

  if (datums && datums.length > 0 && (!redemeers || redemeers.length === 0)) {
    /* (Deprecated)
     ; Note that in the case that a transaction includes datums but does not
     ; include any redeemers, the script data format becomes (in hex):
     ; [ 80 | datums | A0 ]
     ; corresponding to a CBOR empty list and an empty map).
    */
    /* Post Babbage:
     ; [ A0 | datums | A0 ]
    */
    writer.writeEncodedValue(CBOR_EMPTY_MAP);
    writer.writeEncodedValue(getCborEncodedArray(datums));
    writer.writeEncodedValue(CBOR_EMPTY_MAP);
  } else {
    if (!redemeers || redemeers.length === 0) return undefined;
    /*
     ; script data format:
     ; [ redeemers | datums | language views ]
     ; The redeemers are exactly the data present in the transaction witness set.
     ; Similarly for the datums, if present. If no datums are provided, the middle
     ; field is an empty string.
    */
    writer.writeEncodedValue(getCborEncodedArray(redemeers));

    if (datums && datums.length > 0) writer.writeEncodedValue(getCborEncodedArray(datums));

    writer.writeEncodedValue(Buffer.from(costModels.languageViewsEncoding(), 'hex'));
  }

  return Crypto.blake2b.hash(Buffer.from(writer.encode()).toString('hex') as HexBlob, 32);
};

/**
 * Computes the script data hash of a transaction in the Cardano blockchain.
 *
 * This function calculates a hash value that uniquely represents the script data involved in a transaction.
 * It takes into account the cost models of the languages used in the transaction's Plutus scripts,
 * along with the redeemers and datums present in the transaction.
 *
 * If neither redeemers nor datums are present in the transaction, the function returns undefined,
 * as the script data hash is not applicable in this case.
 *
 * @param costModels These models define the computational cost of script execution in different Plutus language versions.
 * @param usedLanguages This array determines which cost models are included in the hash computation.
 * @param redeemers The list of redeemers in the transaction.
 * @param datums The list of datums in the transaction.
 * @returns The hashed script data, or undefined if no redeemers or datums are present in the transaction.
 */
export const computeScriptDataHash = (
  costModels: Cardano.CostModels,
  usedLanguages: Cardano.PlutusLanguageVersion[],
  redeemers?: Cardano.Redeemer[],
  datums?: Cardano.PlutusData[]
): Crypto.Hash32ByteBase16 | undefined => {
  if ((!redeemers || redeemers.length === 0) && (!datums || datums.length === 0)) return undefined;

  const requiredCostModels = new Serialization.Costmdls();

  // We will only include the cost models we need in the hash computation.
  for (const language of usedLanguages) {
    const costModel = costModels.get(language);
    if (costModel) {
      requiredCostModels.insert(new Serialization.CostModel(language, costModel));
    }
  }

  return hashScriptData(
    requiredCostModels,
    redeemers?.map((r) => Serialization.Redeemer.fromCore(r)),
    datums?.map((d) => Serialization.PlutusData.fromCore(d))
  );
};
