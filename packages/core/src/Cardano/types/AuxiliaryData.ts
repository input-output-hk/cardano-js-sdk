/* eslint-disable no-use-before-define */
// Metadatum usage example:
// let metadatum: Metadatum;
// if (typeof metadatum === 'string') {
// } else if (typeof metadatum === 'bigint') {
// } else if (Array.isArray(metadatum)) {
// } else if (metadatum instanceof Uint8Array) {
// } else {
//   // metadatum is MetadatumMap
// }

import * as Cardano from '.';
import { Script } from '@cardano-ogmios/schema';

export { Script } from '@cardano-ogmios/schema';

export interface MetadatumMap {
  [k: string]: Metadatum;
}

export type Metadatum = bigint | MetadatumMap | string | Uint8Array | Array<Metadatum>;

export interface AuxiliaryDataBody {
  blob?: MetadatumMap;
  scripts?: Script[];
}

export interface AuxiliaryData {
  hash?: Cardano.Hash32ByteBase16;
  body: AuxiliaryDataBody;
}
