import { HexBlob, OpaqueString, usingAutoFree } from '@cardano-sdk/util';
import { Transaction } from '../Serialization';
import { cmlUtil } from '../CML';
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
  usingAutoFree((scope) => scope.manage(Transaction.fromCore(scope, tx)).toCbor()) as unknown as TxCBOR;

/**
 * Deserialize transaction from hex-encoded CBOR
 */
TxCBOR.deserialize = async (tx: TxCBOR): Promise<Cardano.Tx> => cmlUtil.deserializeTx(tx);
