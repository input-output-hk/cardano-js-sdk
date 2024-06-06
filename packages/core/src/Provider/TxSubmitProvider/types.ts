import type { HandleResolution, Provider, TxCBOR } from '../../index.js';

type SerializedTransaction = TxCBOR;

export interface SubmitTxArgs {
  signedTransaction: SerializedTransaction;
  context?: { handleResolutions: HandleResolution[] };
}

export interface TxSubmitProvider extends Provider {
  /**
   * @param signedTransaction signed and serialized cbor
   */
  submitTx: (args: SubmitTxArgs) => Promise<void>;
}
