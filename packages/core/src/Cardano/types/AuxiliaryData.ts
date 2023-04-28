import * as Crypto from '@cardano-sdk/crypto';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { Script } from './Script';
import { coreToCml } from '../../CML';
import { usingAutoFree } from '@cardano-sdk/util';

// eslint-disable-next-line no-use-before-define
export type MetadatumMap = Map<Metadatum, Metadatum>;

export type Metadatum = bigint | MetadatumMap | string | Uint8Array | Metadatum[];

export type TxMetadata = Map<bigint, Metadatum>;

export interface AuxiliaryData {
  blob?: TxMetadata;
  scripts?: Script[];
}

export const computeAuxiliaryDataHash = (data: AuxiliaryData | undefined): Hash32ByteBase16 | undefined =>
  usingAutoFree((scope) => {
    if (!data) return;
    const cmlData = coreToCml.txAuxiliaryData(scope, data);
    return Hash32ByteBase16(Crypto.blake2b(Crypto.blake2b.BYTES).update(cmlData!.to_bytes()).digest('hex'));
  });
