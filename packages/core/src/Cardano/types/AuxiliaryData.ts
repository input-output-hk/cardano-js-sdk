import * as Crypto from '@cardano-sdk/crypto';
import * as Serialization from '../../Serialization/AuxiliaryData';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { Script } from './Script';
import { hexToBytes } from '../../util/misc';

// eslint-disable-next-line no-use-before-define
export type MetadatumMap = Map<Metadatum, Metadatum>;

export type Metadatum = bigint | MetadatumMap | string | Uint8Array | Metadatum[];

export type TxMetadata = Map<bigint, Metadatum>;

export interface AuxiliaryData {
  blob?: TxMetadata;
  scripts?: Script[];
}

export const computeAuxiliaryDataHash = (data: AuxiliaryData | undefined): Hash32ByteBase16 | undefined =>
  data
    ? Hash32ByteBase16(
        Crypto.blake2b(Crypto.blake2b.BYTES)
          .update(hexToBytes(Serialization.AuxiliaryData.fromCore(data).toCbor()))
          .digest('hex')
      )
    : undefined;
