import { CML } from '../CML/CML';
import { HexBlob, OpaqueString, usingAutoFree } from '@cardano-sdk/util';
import type { TxCBOR } from './TxCBOR';

/**
 * Transaction body serialized as CBOR, encoded as hex string
 */
export type TxBodyCBOR = OpaqueString<'TxBodyCbor'>;

/**
 * @param tx Serialized as CBOR, encoded as hex string
 * @throws InvalidStringError
 */
export const TxBodyCBOR = (tx: string): TxBodyCBOR => HexBlob(tx) as unknown as TxBodyCBOR;

/**
 * Extract transaction body CBOR without re-serializing
 */
TxBodyCBOR.fromTxCBOR = (txCbor: TxCBOR) =>
  Buffer.from(
    usingAutoFree((scope) =>
      scope.manage(scope.manage(CML.Transaction.from_bytes(Buffer.from(txCbor.toString(), 'hex'))).body()).to_bytes()
    )
  ).toString('hex') as unknown as TxBodyCBOR;
