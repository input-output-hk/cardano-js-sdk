import { HexBlob } from '@cardano-sdk/util';
import { Transaction } from '../Serialization/index.js';
import type { OpaqueString } from '@cardano-sdk/util';
import type { TxCBOR } from './TxCBOR.js';

/** Transaction body serialized as CBOR, encoded as hex string */
export type TxBodyCBOR = OpaqueString<'TxBodyCbor'>;

/**
 * @param tx Serialized as CBOR, encoded as hex string
 * @throws InvalidStringError
 */
export const TxBodyCBOR = (tx: string): TxBodyCBOR => HexBlob(tx) as unknown as TxBodyCBOR;

/** Extract transaction body CBOR without re-serializing */
TxBodyCBOR.fromTxCBOR = (txCbor: TxCBOR) => Transaction.fromCbor(txCbor).body().toCbor() as unknown as TxBodyCBOR;
