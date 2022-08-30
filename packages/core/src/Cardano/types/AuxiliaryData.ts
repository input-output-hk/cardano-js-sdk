import * as Cardano from '.';
import * as fromCore from '../../CSL/coreToCsl';
import * as toCore from '../../CSL/cslToCore';
import { CSL } from '../..';

// eslint-disable-next-line no-use-before-define
export type MetadatumMap = Map<Metadatum, Metadatum>;

export type Metadatum = bigint | MetadatumMap | string | Uint8Array | Metadatum[];

export type TxMetadata = Map<bigint, Metadatum>;

export interface AuxiliaryDataBody {
  blob?: TxMetadata;
  scripts?: Cardano.Script[];
}

export interface AuxiliaryData {
  hash?: Cardano.Hash32ByteBase16;
  body: AuxiliaryDataBody;
}

/**
 * Converts any json object to Metadatum.
 *
 * @param json The json object to be converted.
 * @returns The metadatum.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const jsonToMetadatum = (json: any): Cardano.Metadatum =>
  toCore.txMetadatum(CSL.encode_json_str_to_metadatum(JSON.stringify(json), CSL.MetadataJsonSchema.NoConversions));

/**
 * Converts any Metadatum object to json.
 *
 * @param metadatum The metadatum to be converted to json.
 * @returns The json object.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const metadatumToJson = (metadatum: Cardano.Metadatum): any =>
  CSL.decode_metadatum_to_json_str(fromCore.txMetadatum(metadatum), CSL.MetadataJsonSchema.NoConversions);
