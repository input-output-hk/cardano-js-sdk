/* eslint-disable prettier/prettier */
import { CSL, cslToCore } from '../../CSL';
import { HexBlob } from './primitives';
import { NewTxAlonzo, NewTxBodyAlonzo } from '../types';


export const deserializeTx = ((txBody: Buffer | Uint8Array | string) => {
  const buffer =
    txBody instanceof Buffer
      ? txBody
      : (txBody instanceof Uint8Array
      ? Buffer.from(txBody)
      : Buffer.from(HexBlob(txBody).toString(), 'hex'));

  const txDecoded = CSL.Transaction.from_bytes(buffer);

  return cslToCore.newTx(txDecoded);
}) as (txBody: HexBlob | Buffer | Uint8Array | string) => NewTxAlonzo<NewTxBodyAlonzo>;
