import { Cardano } from '@cardano-sdk/core';

import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import {
  MaybeValidTxOut,
  OutputBuilder,
  OutputValidationMinimumCoinError,
  OutputValidationMissingRequiredError,
  OutputValidationTokenBundleSizeError,
  PartialTxOut
} from './types';
import { OutputValidation } from '../types';
import { OutputValidator } from '../services';

/** Properties needed to construct an {@link ObservableWalletTxOutputBuilder} */
export interface OutputBuilderProps {
  /** This validator is normally created and passed as an arg here by the {@link TxBuilder.buildOutput} method */
  outputValidator: OutputValidator;
  /** Optional partial transaction output to use for initialization. */
  txOut?: PartialTxOut;
}

/** Determines if the `PartialTxOut` arg have at least an address and coins. */
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
 * `OutputBuilder` implementation based on the minimal wallet type: {@link ObservableWalletTxBuilderDependencies}.
 */
export class ObservableWalletTxOutputBuilder implements OutputBuilder {
  /**
   * Transaction output that is updated by `ObservableWalletTxOutputBuilder` methods.
   * Every method call recreates the `partialOutput`, thus updating it immutably.
   */
  #partialOutput: PartialTxOut;
  #outputValidator: OutputValidator;

  constructor({ outputValidator, txOut }: OutputBuilderProps) {
    this.#partialOutput = { ...txOut };
    this.#outputValidator = outputValidator;
  }

  toTxOut(): Cardano.TxOut {
    if (!isViableTxOut(this.#partialOutput)) {
      throw new OutputValidationMissingRequiredError(this.#partialOutput);
    }
    return { ...this.#partialOutput };
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

  async build(): Promise<MaybeValidTxOut> {
    let txOut: Cardano.TxOut;
    try {
      txOut = this.toTxOut();
    } catch (error) {
      return Promise.resolve({
        errors: [error as OutputValidationMissingRequiredError],
        isValid: false
      });
    }

    const outputValidation = toOutputValidationError(txOut, await this.#outputValidator.validateOutput(txOut));
    if (outputValidation) {
      return { errors: [outputValidation], isValid: false };
    }

    return { isValid: true, txOut };
  }
}
