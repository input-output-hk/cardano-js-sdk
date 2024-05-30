import { Cardano, Handle, HandleProvider, Serialization } from '@cardano-sdk/core';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { Logger } from 'ts-log';

import {
  HandleNotFoundError,
  InvalidConfigurationError,
  OutputBuilder,
  OutputBuilderTxOut,
  OutputValidationMinimumCoinError,
  OutputValidationMissingRequiredError,
  OutputValidationNegativeAssetQtyError,
  OutputValidationTokenBundleSizeError,
  PartialTxOut,
  TxOutputFailure
} from './types';
import { OutputValidation, OutputValidator } from '../output-validation';

export type OutputBuilderValidator = Pick<OutputValidator, 'validateOutput'>;

/** Properties needed to construct a {@link TxOutputBuilder} */
export interface OutputBuilderProps {
  /** This validator is normally created and passed as an arg here by the {@link TxBuilder.buildOutput} method */
  outputValidator: OutputBuilderValidator;
  /** Optional partial transaction output to use for initialization. */
  txOut?: PartialTxOut;
  /** Logger */
  logger: Logger;
  /** Handle Provider for resolving addresses */
  handleProvider?: HandleProvider;
}

/** Determines if the `PartialTxOut` arg has at least an address and coins. */
const isViableTxOut = (txOut: PartialTxOut): txOut is Cardano.TxOut =>
  !!((txOut?.address || txOut?.handle) && txOut?.value?.coins);

/**
 * Transforms from `OutputValidation` type emitted by `OutputValidator`, to
 * `OutputValidationMinimumCoinError` | `OutputValidationTokenBundleSizeError`
 */
const toOutputValidationError = (
  txOut: Cardano.TxOut,
  validation: OutputValidation
): OutputValidationMinimumCoinError | OutputValidationTokenBundleSizeError | undefined => {
  if (validation.negativeAssetQty) {
    return new OutputValidationNegativeAssetQtyError(txOut, validation);
  }
  if (validation.coinMissing) {
    return new OutputValidationMinimumCoinError(txOut, validation);
  }
  if (validation.tokenBundleSizeExceedsLimit) {
    return new OutputValidationTokenBundleSizeError(txOut, validation);
  }
};

/** `OutputBuilder` implementation based on {@link OutputValidator}. */
export class TxOutputBuilder implements OutputBuilder {
  /**
   * Transaction output that is updated by `TxOutputBuilder` methods.
   * Every method call recreates the `partialOutput`, thus updating it immutably.
   */
  #partialOutput: PartialTxOut;
  #outputValidator: OutputBuilderValidator;
  #logger: Logger;
  #handleProvider: HandleProvider | null = null;

  constructor({ outputValidator, txOut, logger, handleProvider }: OutputBuilderProps) {
    this.#partialOutput = { ...txOut };
    this.#outputValidator = outputValidator;
    this.#logger = logger;

    if (handleProvider) {
      this.#handleProvider = handleProvider;
    }
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
  toTxOut(): OutputBuilderTxOut {
    if (!isViableTxOut(this.#partialOutput)) {
      throw new OutputValidationMissingRequiredError(this.#partialOutput);
    }
    this.#logger.debug('toTxOut result:', this.#partialOutput);
    return { ...this.#partialOutput };
  }

  async inspect(): Promise<PartialTxOut> {
    return this.#partialOutput;
  }

  value(value: Cardano.Value): TxOutputBuilder {
    this.#partialOutput = { ...this.#partialOutput, value: { ...value } };
    return this;
  }

  coin(coin: Cardano.Lovelace): TxOutputBuilder {
    this.#partialOutput = { ...this.#partialOutput, value: { ...this.#partialOutput?.value, coins: coin } };
    return this;
  }

  assets(assets: Cardano.TokenMap): TxOutputBuilder {
    this.#partialOutput = {
      ...this.#partialOutput,
      value: { ...this.#partialOutput?.value, assets }
    };
    return this;
  }

  asset(assetId: Cardano.AssetId, quantity: bigint): TxOutputBuilder {
    const assets: Cardano.TokenMap = new Map(this.#partialOutput?.value?.assets);
    quantity === 0n ? assets.delete(assetId) : assets.set(assetId, quantity);

    return this.assets(assets);
  }

  address(address: Cardano.PaymentAddress): TxOutputBuilder {
    this.#partialOutput = { ...this.#partialOutput, address };
    return this;
  }

  datum(datum: Hash32ByteBase16 | Cardano.PlutusData): TxOutputBuilder {
    if (Serialization.isDatumHash(datum)) {
      this.#partialOutput = { ...this.#partialOutput, datumHash: datum };
    } else {
      this.#partialOutput = { ...this.#partialOutput, datum };
    }

    return this;
  }

  scriptReference(script: Cardano.Script) {
    if (!Cardano.isPlutusScript(script)) throw new Error('Only plutus scripts can be added as reference scripts.');

    this.#partialOutput = { ...this.#partialOutput, scriptReference: script };

    return this;
  }

  handle(handle: Handle): TxOutputBuilder {
    if (!this.#handleProvider) {
      throw new InvalidConfigurationError(TxOutputFailure.MissingHandleProviderError);
    }

    this.#partialOutput = { ...this.#partialOutput, handle };

    return this;
  }

  async build(): Promise<OutputBuilderTxOut> {
    const txOut = this.toTxOut();

    if (this.#partialOutput.handle && this.#handleProvider) {
      const resolution = await this.#handleProvider.resolveHandles({ handles: [this.#partialOutput.handle] });

      if (resolution[0] !== null) {
        txOut.handleResolution = resolution[0];
        txOut.address = resolution[0].cardanoAddress;
      } else {
        // Throw an error because the handle resolved to null so we don't have
        // an address for the transaction.
        throw new HandleNotFoundError(this.#partialOutput);
      }
    }

    const outputValidation = toOutputValidationError(txOut, await this.#outputValidator.validateOutput(txOut));
    if (outputValidation) {
      throw outputValidation;
    }

    return txOut;
  }
}
