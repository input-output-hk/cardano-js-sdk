import { Address, Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { BigIntMath } from '@cardano-sdk/util';
import { Observable, firstValueFrom } from 'rxjs';
import { OutputValidation } from '../types';
import { computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit } from '@cardano-sdk/cip2';
import { txInEquals } from './util';

export type ProtocolParametersRequiredByOutputValidator = Pick<
  ProtocolParametersRequiredByWallet,
  'coinsPerUtxoByte' | 'maxValueSize'
>;
export interface OutputValidatorContext {
  /**
   * Subscribed on every OutputValidator call
   */
  protocolParameters$: Observable<ProtocolParametersRequiredByOutputValidator>;
}
export interface InputResolverContext {
  utxo: {
    /**
     * Subscribed on every InputResolver call
     */
    available$: Observable<Cardano.Utxo[]>;
  };
}
export type WalletUtilContext = OutputValidatorContext & InputResolverContext;

export interface OutputValidator {
  /**
   * Assumes that value will be used with an output that has:
   * - no datum
   * - grouped address (Shelley era+)
   *
   * @returns Validates that token bundle size is within limits and computes minimum coin quantity
   */
  validateValue(output: Cardano.Value): Promise<OutputValidation>;
  /**
   * Assumes that values will be used with outputs that have:
   * - no datum
   * - grouped address (Shelley era+)
   *
   * @returns For every value, validates that token bundle size is within limits and computes minimum coin quantity
   */
  validateValues(outputs: Iterable<Cardano.Value>): Promise<Map<Cardano.Value, OutputValidation>>;
  /**
   * @returns Validates that token bundle size is within limits and computes minimum coin quantity
   */
  validateOutput(output: Cardano.TxOut): Promise<OutputValidation>;
  /**
   * @returns For every output, validates that token bundle size is within limits and computes minimum coin quantity
   */
  validateOutputs(outputs: Iterable<Cardano.TxOut>): Promise<Map<Cardano.TxOut, OutputValidation>>;
}

export const createOutputValidator = ({ protocolParameters$ }: OutputValidatorContext): OutputValidator => {
  const validateValue = async (
    value: Cardano.Value,
    protocolParameters?: ProtocolParametersRequiredByOutputValidator
  ): Promise<OutputValidation> => {
    const { coinsPerUtxoByte, maxValueSize } = protocolParameters || (await firstValueFrom(protocolParameters$));
    const stubMaxSizeAddress = Cardano.Address(
      'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
    );
    const stubTxOut: Cardano.TxOut = { address: stubMaxSizeAddress, value };
    const minimumCoin = BigInt(computeMinimumCoinQuantity(coinsPerUtxoByte)(stubTxOut));
    return {
      coinMissing: BigIntMath.max([minimumCoin - value.coins, 0n])!,
      minimumCoin,
      tokenBundleSizeExceedsLimit: tokenBundleSizeExceedsLimit(maxValueSize)(value.assets)
    };
  };
  const validateValues = async (values: Iterable<Cardano.Value>) => {
    const protocolParameters = await firstValueFrom(protocolParameters$);
    const validations = new Map<Cardano.Value, OutputValidation>();
    for (const value of values) {
      validations.set(value, await validateValue(value, protocolParameters));
    }
    return validations;
  };
  const validateOutput = async (
    output: Cardano.TxOut,
    protocolParameters?: ProtocolParametersRequiredByOutputValidator
  ) => {
    const { coinsPerUtxoByte, maxValueSize } = protocolParameters || (await firstValueFrom(protocolParameters$));
    const minimumCoin = BigInt(computeMinimumCoinQuantity(coinsPerUtxoByte)(output));
    return {
      coinMissing: BigIntMath.max([minimumCoin - output.value.coins, 0n])!,
      minimumCoin,
      tokenBundleSizeExceedsLimit: tokenBundleSizeExceedsLimit(maxValueSize)(output.value.assets)
    };
  };

  return {
    validateOutput,
    async validateOutputs(outputs: Iterable<Cardano.TxOut>): Promise<Map<Cardano.TxOut, OutputValidation>> {
      const protocolParameters = await firstValueFrom(protocolParameters$);
      const validations = new Map<Cardano.TxOut, OutputValidation>();
      for (const output of outputs) {
        validations.set(output, await validateOutput(output, protocolParameters));
      }
      return validations;
    },
    validateValue,
    validateValues
  };
};

export const createInputResolver = ({ utxo }: InputResolverContext): Address.util.InputResolver => ({
  async resolveInputAddress(input: Cardano.NewTxIn) {
    const utxoAvailable = await firstValueFrom(utxo.available$);
    return utxoAvailable?.find(([txIn]) => txInEquals(txIn, input))?.[1].address || null;
  }
});

/**
 * @returns common wallet utility functions that are aware of wallet state and computes useful things
 */
export const createWalletUtil = (context: WalletUtilContext) => ({
  ...createOutputValidator(context),
  ...createInputResolver(context)
});

export type WalletUtil = ReturnType<typeof createWalletUtil>;

type SetWalletUtilContext = (context: WalletUtilContext) => void;

/**
 * Creates a WalletUtil that has an additional function to `initialize` by setting the context.
 * Calls to WalletUtil functions will only resolve after initializing.
 *
 * @returns common wallet utility functions that are aware of wallet state and computes useful things
 */
export const createLazyWalletUtil = (): WalletUtil & { initialize: SetWalletUtilContext } => {
  let initialize: SetWalletUtilContext;
  const resolverReady = new Promise((resolve: SetWalletUtilContext) => (initialize = resolve)).then(createWalletUtil);
  return {
    initialize: initialize!,
    async resolveInputAddress(input) {
      const resolver = await resolverReady;
      return resolver.resolveInputAddress(input);
    },
    async validateOutput(output) {
      const resolver = await resolverReady;
      return resolver.validateOutput(output);
    },
    async validateOutputs(outputs) {
      const resolver = await resolverReady;
      return resolver.validateOutputs(outputs);
    },
    async validateValue(value) {
      const resolver = await resolverReady;
      return resolver.validateValue(value);
    },
    async validateValues(values) {
      const resolver = await resolverReady;
      return resolver.validateValues(values);
    }
  };
};
