// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import Cardano, { HandleResolution, Provider } from '../..';

type SerializedTransaction = Cardano.util.HexBlob;

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
