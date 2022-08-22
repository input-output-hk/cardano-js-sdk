// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import Cardano, { Provider } from '../..';

type SerializedTransaction = Cardano.util.HexBlob;

export interface SubmitTxArgs {
  signedTransaction: SerializedTransaction;
}

export interface TxSubmitProvider extends Provider {
  /**
   * @param signedTransaction signed and serialized cbor
   * @throws {Cardano.TxSubmissionError} (see Cardano.TxSubmissionErrors)
   */
  submitTx: (args: SubmitTxArgs) => Promise<void>;
}
