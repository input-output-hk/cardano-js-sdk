import { HexBlob, OpaqueString } from '@cardano-sdk/util';
import { Transaction } from '../Serialization';
import { Tx, TxBody } from '../Cardano/types/Transaction';
import type { Cardano } from '..';

/** Transaction serialized as CBOR, encoded as hex string */
export type TxCBOR = OpaqueString<'TxCbor'>;

/**
 * @param tx Serialized as CBOR, encoded as hex string
 * @throws InvalidStringError
 */
export const TxCBOR = (tx: string): TxCBOR => HexBlob(tx) as unknown as TxCBOR;

export const deserializeTx = ((txBody: Buffer | Uint8Array | string) => {
  const hex =
    txBody instanceof Buffer
      ? txBody.toString('hex')
      : txBody instanceof Uint8Array
      ? Buffer.from(txBody).toString('hex')
      : txBody;

  const transaction = Transaction.fromCbor(TxCBOR(hex));
  return transaction.toCore();
}) as (txBody: HexBlob | Buffer | Uint8Array | string) => Tx<TxBody>;

/** Serialize transaction to hex-encoded CBOR */
TxCBOR.serialize = (tx: Cardano.Tx): TxCBOR => Transaction.fromCore(tx).toCbor() as unknown as TxCBOR;

/** Deserialize transaction from hex-encoded CBOR */
TxCBOR.deserialize = (tx: TxCBOR): Cardano.Tx => deserializeTx(tx);
