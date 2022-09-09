import { Cardano } from '@cardano-sdk/core';

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

/** Determines if the `PartialTxOut` arg have at least an address and coins. */
const isViableTxOut = (txOut: PartialTxOut): txOut is Cardano.TxOut => !!(txOut?.address && txOut?.value?.coins);

/**
 * Transforms from `OutputValidation` type emitted by `OutputValidator`, to
 * `OutputValidationMinimumCoinError` | `OutputValidationTokenBundleSizeError`
 */
export const toOutputValidationError = (
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
 * `OutputBuilder` implementation based on the minimal wallet type.
 */
export class ObservableWalletTxOutputBuilder implements OutputBuilder {
  partialOutput: PartialTxOut;

  #outputValidator: OutputValidator;

  /**
   *
   * @param outputValidator this validator is normally created and passed as an arg here, by the TxBuilder
   * @param txOut optional partial transaction output to use for initialization.
   */
  constructor(outputValidator: OutputValidator, txOut?: PartialTxOut) {
    this.partialOutput = { ...txOut };
    this.#outputValidator = outputValidator;
  }

  value(value: Cardano.Value): OutputBuilder {
    this.partialOutput = { ...this.partialOutput, value: { ...value } };
    return this;
  }

  coin(coin: Cardano.Lovelace): OutputBuilder {
    this.partialOutput = { ...this.partialOutput, value: { ...this.partialOutput?.value, coins: coin } };
    return this;
  }

  assets(assets: Cardano.TokenMap): OutputBuilder {
    this.partialOutput = {
      ...this.partialOutput,
      value: { ...this.partialOutput?.value, assets }
    };
    return this;
  }

  asset(assetId: Cardano.AssetId, quantity: bigint): OutputBuilder {
    const assets: Cardano.TokenMap = new Map(this.partialOutput?.value?.assets);
    quantity === 0n ? assets.delete(assetId) : assets.set(assetId, quantity);

    return this.assets(assets);
  }

  address(address: Cardano.Address): OutputBuilder {
    this.partialOutput = { ...this.partialOutput, address };
    return this;
  }

  datum(datum: Cardano.util.Hash32ByteBase16): OutputBuilder {
    this.partialOutput = { ...this.partialOutput, datum };
    return this;
  }

  async build(): Promise<MaybeValidTxOut> {
    if (!isViableTxOut(this.partialOutput)) {
      return Promise.resolve({
        errors: [new OutputValidationMissingRequiredError(this.partialOutput)],
        isValid: false
      });
    }

    const outputValidation = toOutputValidationError(
      this.partialOutput,
      await this.#outputValidator.validateOutput(this.partialOutput)
    );
    if (outputValidation) {
      return { errors: [outputValidation], isValid: false };
    }

    return { isValid: true, txOut: this.partialOutput };
  }
}
