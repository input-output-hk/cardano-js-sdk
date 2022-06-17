/* eslint-disable prettier/prettier */

import { CSL, Cardano, cslToCore } from '../..';

export const deserializeTx = ((txBody: Buffer | Uint8Array | string) => {
  const buffer =
    txBody instanceof Buffer
      ? txBody
      : (txBody instanceof Uint8Array
      ? Buffer.from(txBody)
      : Buffer.from(Cardano.util.HexBlob(txBody).toString(), 'hex'));

  const txDecoded = CSL.Transaction.from_bytes(buffer);

  return cslToCore.newTx(txDecoded);
}) as (txBody: Cardano.util.HexBlob | Buffer | Uint8Array | string) => Cardano.NewTxAlonzo<Cardano.NewTxBodyAlonzo>;
