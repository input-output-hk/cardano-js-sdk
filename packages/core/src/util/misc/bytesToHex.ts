import { HexBlob } from '@cardano-sdk/util';

export const bytesToHex = (bytes: Uint8Array): HexBlob => HexBlob(Buffer.from(bytes).toString('hex'));
