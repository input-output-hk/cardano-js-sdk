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
  const validateOutput = async (
    { address, value }: Cardano.TxOut,
    protocolParameters?: ProtocolParametersRequiredByOutputValidator
  ) => {
    const { coinsPerUtxoByte, maxValueSize } = protocolParameters || (await protocolParametersGetter());
    const stubTxOut: Cardano.TxOut = { address, value };
    const negativeAssetQty = value.assets ? [...value.assets.values()].some((qty) => qty <= 0) : false;
    if (negativeAssetQty) {
      // return early, otherwise 'minimumCoin/maxValueSize' will fail with error: "ParseIntError { kind: InvalidDigit }"
      return {
        coinMissing: 0n,
        minimumCoin: 0n,
        negativeAssetQty,
        tokenBundleSizeExceedsLimit: false
      };
    }
    const minimumCoin = BigInt(computeMinimumCoinQuantity(coinsPerUtxoByte)(stubTxOut));
    return {
      coinMissing: BigIntMath.max([minimumCoin - value.coins, 0n])!,
      minimumCoin,
      negativeAssetQty,
      tokenBundleSizeExceedsLimit: tokenBundleSizeExceedsLimit(maxValueSize)(value.assets)
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
    }
  };
};
