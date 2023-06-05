// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import Cardano, { CardanoNodeErrors, HandleResolution, Provider } from '../..';

type SerializedTransaction = Cardano.util.HexBlob;

export interface SubmitTxArgs {
  signedTransaction: SerializedTransaction;
  context?: { handles: HandleResolution[] };
}

export interface TxSubmitProvider extends Provider {
  /**
   * @param signedTransaction signed and serialized cbor
   * @throws {CardanoNodeErrors.TxSubmissionError}
   */
  submitTx: (args: SubmitTxArgs) => Promise<void>;
}
