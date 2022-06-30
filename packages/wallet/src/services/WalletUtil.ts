import { BigIntMath } from '@cardano-sdk/util';
import { Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { ObservableWalletCore, OutputValidation } from '../types';
import { ResolveInputAddress } from '../KeyManagement';
import { computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit } from '@cardano-sdk/cip2';
import { firstValueFrom } from 'rxjs';
import { txInEquals } from './util';

/**
 * @returns common wallet utility functions that are aware of wallet state and computes useful things
 */
// Review: internal uses always reference core variant of the wallet
export const createWalletUtil = (wallet: ObservableWalletCore) => {
  const validateOutput = async (
    output: Cardano.TxOut,
    protocolParameters?: Pick<ProtocolParametersRequiredByWallet, 'coinsPerUtxoWord' | 'maxValueSize'>
  ): Promise<OutputValidation> => {
    const { coinsPerUtxoWord, maxValueSize } = protocolParameters || (await firstValueFrom(wallet.protocolParameters$));
    const minimumCoin = BigInt(computeMinimumCoinQuantity(coinsPerUtxoWord)(output.value.assets));
    return {
      coinMissing: BigIntMath.max([minimumCoin - output.value.coins, 0n])!,
      minimumCoin,
      tokenBundleSizeExceedsLimit: tokenBundleSizeExceedsLimit(maxValueSize)(output.value.assets)
    };
  };
  const resolveInputAddress: ResolveInputAddress = async (input: Cardano.NewTxIn) => {
    const utxoAvailable = await firstValueFrom(wallet.utxo.available$);
    return utxoAvailable?.find(([txIn]) => txInEquals(txIn, input))?.[1].address || null;
  };

  return {
    resolveInputAddress,
    /**
     * @returns Validates that token bundle size is within limits and computes minimum coin quantity
     */
    validateOutput,
    /**
     * @returns For every output, validates that token bundle size is within limits and computes minimum coin quantity
     */
    validateOutputs: async (outputs: Iterable<Cardano.TxOut>): Promise<Map<Cardano.TxOut, OutputValidation>> => {
      const protocolParameters = await firstValueFrom(wallet.protocolParameters$);
      const validations = new Map<Cardano.TxOut, OutputValidation>();
      for (const output of outputs) {
        validations.set(output, await validateOutput(output, protocolParameters));
      }
      return validations;
    }
  };
};

export type WalletUtil = ReturnType<typeof createWalletUtil>;
