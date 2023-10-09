import { fromMetadatum } from './fromMetadatum';
import { fromPlutusData } from './fromPlutusData';

import { NftMetadata as _NftMetadata } from './types';

export * from './types';
export * from './errors';

// tsc requires the type and object, sharing a name, to be exported from the same module (re-export syntax for the type doesn't work)
export type NftMetadata = _NftMetadata;
export const NftMetadata = {
  fromMetadatum,
  fromPlutusData
};
