import type * as Crypto from '@cardano-sdk/crypto';
import type { PaymentAddress } from './../Address/index.js';
import type { PlutusData } from './PlutusData.js';
import type { Script } from './Script.js';
import type { TransactionId } from './Transaction.js';
import type { Value } from './Value.js';

/**
 * Datum hash, this allows to specify a Datum without publicly revealing its value. To spend an output which specifies
 * this type of datum, the actual Datum value must be provided and will be added to the witness set of
 * the transaction.
 */
export type DatumHash = Crypto.Hash32ByteBase16;

export interface TxIn {
  txId: TransactionId;
  index: number;
}

export interface HydratedTxIn extends TxIn {
  address: PaymentAddress;
}

export interface TxOut {
  address: PaymentAddress;
  value: Value;

  /**
   * Datum hash, this allows to specify a Datum without publicly revealing its value. To spend an output which specifies
   * this type of datum, the actual Datum value must be provided and will be added to the witness set of
   * the transaction.
   */
  datumHash?: DatumHash;

  /**
   * The datum value can also be inlined in the output revealing the value on the blockchain at the time of output
   * creation. This way of attaching datums lets users consume this output without specifying the datum value.
   */
  datum?: PlutusData;

  /**
   * Reference scripts can be used to satisfy script requirements during validation, rather than requiring the spending
   * transaction to do so. This allows transactions using common scripts to be much smaller.
   *
   * The key idea is to use reference inputs and outputs which carry actual scripts ("reference scripts"), and allow
   * such reference scripts to satisfy the script witnessing requirement for a transaction. This means that the
   * transaction which uses the script will not need to provide it at all, so long as it referenced an output
   * which contained the script.
   */
  scriptReference?: Script;
}

export type Utxo = [HydratedTxIn, TxOut];
