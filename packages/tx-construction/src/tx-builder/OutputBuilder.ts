import { Cardano, Handle, KoraLabsHandleProvider } from '@cardano-sdk/core';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { Logger } from 'ts-log';

import {
  OutputBuilder,
  OutputValidationMinimumCoinError,
  OutputValidationMissingRequiredError,
  OutputValidationTokenBundleSizeError,
  PartialTxOut
} from './types';
import { OutputValidation, OutputValidator } from '../output-validation';

/** Properties needed to construct a {@link TxOutputBuilder} */
export interface OutputBuilderProps {
  /** This validator is normally created and passed as an arg here by the {@link TxBuilder.buildOutput} method */
  outputValidator: OutputValidator;
  /** Optional partial transaction output to use for initialization. */
  txOut?: PartialTxOut;
  /** Logger */
  logger: Logger;
  /** Koralabs Handle Provider for ADAHandle */
  handleProvider: KoraLabsHandleProvider;
}

/** Determines if the `PartialTxOut` arg has at least an address and coins. */
const isViableTxOut = (txOut: PartialTxOut): txOut is Cardano.TxOut => !!(txOut?.address && txOut?.value?.coins);

/**
 * Transforms from `OutputValidation` type emitted by `OutputValidator`, to
 * `OutputValidationMinimumCoinError` | `OutputValidationTokenBundleSizeError`
 */
const toOutputValidationError = (
  txOut: Cardano.TxOut,
  validation: OutputValidation
): OutputValidationMinimumCoinError | OutputValidationTokenBundleSizeError | undefined => {
  if (validation.coinMissing) {
    return new OutputValidationMinimumCoinError(txOut, validation);
  }
  if (validation.tokenBundleSizeExceedsLimit) {
    return new OutputValidationTokenBundleSizeError(txOut, validation);
  }
};

/**
 * `OutputBuilder` implementation based on {@link OutputValidator}.
 */
export class TxOutputBuilder implements OutputBuilder {
  /**
   * Transaction output that is updated by `TxOutputBuilder` methods.
   * Every method call recreates the `partialOutput`, thus updating it immutably.
   */
  #partialOutput: PartialTxOut;
  #outputValidator: OutputValidator;
  #logger: Logger;
  #handleProvider: KoraLabsHandleProvider;

  constructor({ outputValidator, txOut, logger, handleProvider }: OutputBuilderProps) {
    this.#partialOutput = { ...txOut };
    this.#outputValidator = outputValidator;
    this.#logger = logger;
    this.#handleProvider = handleProvider;
  }

  /**
   * Create transaction output snapshot, as it was configured until the point of calling this method.
   *
   * @returns {Cardano.TxOut} transaction output snapshot.
   *  - It can be used in {@link TxBuilder.addOutput}.
   *  - It will be validated once {@link TxBuilder.build} method is called.
   * @throws OutputValidationMissingRequiredError {@link OutputValidationMissingRequiredError} if
   * the mandatory fields 'address' or 'coins' are missing
   */
  toTxOut(): Cardano.TxOut {
    if (!isViableTxOut(this.#partialOutput)) {
      throw new OutputValidationMissingRequiredError(this.#partialOutput);
    }
    this.#logger.debug('toTxOut result:', this.#partialOutput);
    return { ...this.#partialOutput };
  }

  async inspect(): Promise<PartialTxOut> {
    return this.#partialOutput;
  }

  value(value: Cardano.Value): OutputBuilder {
    this.#partialOutput = { ...this.#partialOutput, value: { ...value } };
    return this;
  }

  coin(coin: Cardano.Lovelace): OutputBuilder {
    this.#partialOutput = { ...this.#partialOutput, value: { ...this.#partialOutput?.value, coins: coin } };
    return this;
  }

  assets(assets: Cardano.TokenMap): OutputBuilder {
    this.#partialOutput = {
      ...this.#partialOutput,
      value: { ...this.#partialOutput?.value, assets }
    };
    return this;
  }

  asset(assetId: Cardano.AssetId, quantity: bigint): OutputBuilder {
    const assets: Cardano.TokenMap = new Map(this.#partialOutput?.value?.assets);
    quantity === 0n ? assets.delete(assetId) : assets.set(assetId, quantity);

    return this.assets(assets);
  }

  address(address: Cardano.PaymentAddress): OutputBuilder {
    this.#partialOutput = { ...this.#partialOutput, address };
    return this;
  }

  datum(datumHash: Hash32ByteBase16): OutputBuilder {
    this.#partialOutput = { ...this.#partialOutput, datumHash };
    return this;
  }

  // make it take an output that has type AdaHandle
  handle(output: Handle): OutputBuilder {
    // output/handle: $AdaHandle
    this.#handleProvider
      .resolveHandles({ handles: [output] })
      .then(() => {
        this.#partialOutput = { ...this.#partialOutput, handle: output };

        return this;
      })
      .catch((error) => {
        throw new Error(error);
      });
    return this;
  }

  async build(): Promise<Cardano.TxOut> {
    const txOut = this.toTxOut();

    const outputValidation = toOutputValidationError(txOut, await this.#outputValidator.validateOutput(txOut));
    if (outputValidation) {
      throw outputValidation;
    }

    if (this.#partialOutput.handle) {
      // eslint-disable-next-line no-console
      console.log('ADA handle:', this.#partialOutput.handle);
    }

    return txOut;
  }
}
