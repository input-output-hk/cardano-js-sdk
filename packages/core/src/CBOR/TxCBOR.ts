import { HexBlob, OpaqueString, bufferToHexString, usingAutoFree } from '@cardano-sdk/util';
import { cmlUtil, coreToCml } from '../CML';
import type { Cardano } from '..';

/**
 * Transaction serialized as CBOR, encoded as hex string
 */
export type TxCBOR = OpaqueString<'TxCbor'>;

/**
 * @param tx Serialized as CBOR, encoded as hex string
 * @throws InvalidStringError
 */
export const TxCBOR = (tx: string): TxCBOR => HexBlob(tx) as unknown as TxCBOR;

/**
 * Serialize transaction to hex-encoded CBOR
 */
TxCBOR.serialize = (tx: Cardano.Tx): TxCBOR =>
  bufferToHexString(Buffer.from(usingAutoFree((scope) => coreToCml.tx(scope, tx).to_bytes()))) as unknown as TxCBOR;

/**
 * Deserialize transaction from hex-encoded CBOR
 */
TxCBOR.deserialize = (tx: TxCBOR): Cardano.Tx => cmlUtil.deserializeTx(tx);
