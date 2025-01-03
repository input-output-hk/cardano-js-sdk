import { BlockfrostClient, BlockfrostProvider } from '../blockfrost';
import { Logger } from 'ts-log';
import {
  ProviderError,
  SubmitTxArgs,
  TxSubmissionError,
  TxSubmissionErrorCode,
  TxSubmitProvider,
  ValueNotConservedData
} from '@cardano-sdk/core';

type BlockfrostTxSubmissionErrorMessage = {
  contents: {
    contents: {
      contents: {
        error: [string];
      };
    };
  };
};

const tryParseBlockfrostTxSubmissionErrorMessage = (
  errorMessage: string
): BlockfrostTxSubmissionErrorMessage | null => {
  try {
    const error = JSON.parse(errorMessage);
    if (typeof error === 'object' && Array.isArray(error?.contents?.contents?.contents?.error)) {
      return error;
    }
  } catch {
    return null;
  }
  return null;
};

/**
 * @returns TxSubmissionError if sucessfully mapped, otherwise `null`
 */
const tryMapTxBlockfrostSubmissionError = (error: ProviderError): TxSubmissionError | null => {
  try {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const detail = JSON.parse(error.detail as any);
    if (typeof detail?.message === 'string') {
      const blockfrostTxSubmissionErrorMessage = tryParseBlockfrostTxSubmissionErrorMessage(detail.message);
      if (!blockfrostTxSubmissionErrorMessage) {
        return null;
      }
      const message = blockfrostTxSubmissionErrorMessage.contents.contents.contents.error[0];
      if (message.includes('OutsideValidityIntervalUTxO')) {
        // error also contains information about validity interval and actual slots,
        // but we're currently not using this info
        return new TxSubmissionError(TxSubmissionErrorCode.OutsideOfValidityInterval, null, message);
      }
      // eslint-disable-next-line wrap-regex
      const valueNotConservedMatch = /ValueNotConservedUTxO.+Coin (\d+).+Coin (\d+)/.exec(message);
      if (valueNotConservedMatch) {
        const consumed = BigInt(valueNotConservedMatch[1]);
        const produced = BigInt(valueNotConservedMatch[2]);
        const valueNotConservedData: ValueNotConservedData = {
          // error also contains information about consumed and produced native assets
          // but we're currently not using this info
          consumed: { coins: consumed },
          produced: { coins: produced }
        };
        return new TxSubmissionError(TxSubmissionErrorCode.ValueNotConserved, valueNotConservedData, message);
      }
    }
  } catch {
    return null;
  }

  return null;
};

export class BlockfrostTxSubmitProvider extends BlockfrostProvider implements TxSubmitProvider {
  constructor(client: BlockfrostClient, logger: Logger) {
    super(client, logger);
  }

  async submitTx({ signedTransaction }: SubmitTxArgs): Promise<void> {
    // @ todo handle context and resolutions
    try {
      await this.request<string>('tx/submit', {
        body: Buffer.from(signedTransaction, 'hex'),
        headers: { 'Content-Type': 'application/cbor' },
        method: 'POST'
      });
    } catch (error) {
      if (error instanceof ProviderError) {
        const submissionError = tryMapTxBlockfrostSubmissionError(error);
        if (submissionError) {
          throw new ProviderError(error.reason, submissionError, error.detail);
        }
      }
      throw error;
    }
  }
}
