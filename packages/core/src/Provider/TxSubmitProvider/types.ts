// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import Cardano, { Provider } from '../..';

export interface TxSubmitProvider extends Provider {
  /**
   * @param signedTransaction signed and serialized cbor
   * @throws {Cardano.TxSubmissionError} (see Cardano.TxSubmissionErrors)
   */
  submitTx: (signedTransaction: Uint8Array) => Promise<void>;
}
