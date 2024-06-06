import { fromMetadatum } from './fromMetadatum.js';
import { fromPlutusData } from './fromPlutusData.js';

import type { NftMetadata as _NftMetadata } from './types.js';

export * from './types.js';
export * from './errors.js';

// tsc requires the type and object, sharing a name, to be exported from the same module (re-export syntax for the type doesn't work)
export type NftMetadata = _NftMetadata;
export const NftMetadata = {
  fromMetadatum,
  fromPlutusData
};
