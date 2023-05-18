import { BigIntMath } from '@cardano-sdk/util';
import { Cardano } from '@cardano-sdk/core';

import {
  OutputValidation,
  OutputValidator,
  OutputValidatorContext,
  ProtocolParametersRequiredByOutputValidator
} from './types';
import { computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit } from '../input-selection';

export const createOutputValidator = ({
  protocolParameters: protocolParametersGetter
}: OutputValidatorContext): OutputValidator => {
  const validateValue = async (
    value: Cardano.Value,
    protocolParameters?: ProtocolParametersRequiredByOutputValidator
  ): Promise<OutputValidation> => {
    const { coinsPerUtxoByte, maxValueSize } = protocolParameters || (await protocolParametersGetter());
    const stubMaxSizeAddress = Cardano.PaymentAddress(
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
    const protocolParameters = await protocolParametersGetter();
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
    const { coinsPerUtxoByte, maxValueSize } = protocolParameters || (await protocolParametersGetter());
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
      const protocolParameters = await protocolParametersGetter();
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
