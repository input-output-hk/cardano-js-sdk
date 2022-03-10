// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import Cardano from '../..';

export interface TxSubmitProvider {
  /**
   * @param signedTransaction signed and serialized cbor
   * @throws {Cardano.TxSubmissionError} (see Cardano.TxSubmissionErrors)
   */
  submitTx: (signedTransaction: Uint8Array) => Promise<void>;
}
