/* eslint-disable no-bitwise */
import { BigIntMath } from '@cardano-sdk/util';
import { Cardano } from '@cardano-sdk/core';
import { Observable, firstValueFrom } from 'rxjs';
import { ObservableWallet, OutputValidation } from '../types';
import { computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit } from '@cardano-sdk/tx-construction';
import { txInEquals } from './util';
import uniqBy from 'lodash/uniqBy';

export type ProtocolParametersRequiredByOutputValidator = Pick<
  Cardano.ProtocolParameters,
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

export const createInputResolver = ({ utxo }: InputResolverContext): Cardano.InputResolver => ({
  async resolveInputAddress(input: Cardano.TxIn) {
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

/**
 * Gets whether the given TX requires signatures that can not be provided by the given wallet.
 *
 * @param tx The transaction to inspect.
 * @param wallet The wallet that will provide the signatures.
 * @returns true if the wallet can not sign all inputs/certificates; otherwise; false.
 */
// eslint-disable-next-line complexity, sonarjs/cognitive-complexity
export const requiresForeignSignatures = async (tx: Cardano.Tx, wallet: ObservableWallet): Promise<boolean> => {
  const utxoSet = await firstValueFrom(wallet.utxo.total$);
  const knownAddresses = await firstValueFrom(wallet.addresses$);
  const uniqueAccounts = uniqBy(knownAddresses, 'rewardAccount').map((groupedAddress) => {
    const stakeKeyHash = Cardano.RewardAccount.toHash(groupedAddress.rewardAccount);
    return {
      poolId: Cardano.PoolId.fromKeyHash(stakeKeyHash),
      rewardAccount: groupedAddress.rewardAccount,
      stakeKeyHash
    };
  });

  // Iterate over the inputs and see if all of them are present in our UTXO set.
  for (const input of tx.body.inputs) {
    const ownsInput = utxoSet.find(
      (utxo: Cardano.Utxo) => input.txId === utxo[0].txId && input.index === utxo[0].index
    );

    if (!ownsInput) return true;
  }

  // Iterate over the collateral inputs and see if all of them are present in our UTXO set.
  if (tx.body.collaterals) {
    for (const input of tx.body.collaterals) {
      const ownsInput = utxoSet.find(
        (utxo: Cardano.Utxo) => input.txId === utxo[0].txId && input.index === utxo[0].index
      );

      if (!ownsInput) return true;
    }
  }

  // If all inputs are accounted for, see if all certificates belong to any of our reward accounts.
  if (!tx.body.certificates) return false;

  for (const certificate of tx.body.certificates) {
    let matchesOneAccount = false;

    for (const account of uniqueAccounts) {
      switch (certificate.__typename) {
        case Cardano.CertificateType.StakeKeyDeregistration:
        case Cardano.CertificateType.StakeDelegation:
          if (certificate.stakeKeyHash === account.stakeKeyHash) matchesOneAccount = true;
          break;
        case Cardano.CertificateType.PoolRegistration:
          for (const owner of certificate.poolParameters.owners) {
            // eslint-disable-next-line max-depth
            if (owner === account.rewardAccount) matchesOneAccount = true;
          }
          break;
        case Cardano.CertificateType.PoolRetirement:
          if (certificate.poolId === account.poolId) matchesOneAccount = true;
          break;
        case Cardano.CertificateType.MIR:
          if (certificate.rewardAccount === account.rewardAccount) matchesOneAccount = true;
          break;
        case Cardano.CertificateType.StakeKeyRegistration:
        case Cardano.CertificateType.GenesisKeyDelegation:
        default:
          // These certificates don't require our signature, so we will map them as 'accounted for'.
          matchesOneAccount = true;
      }
    }

    // If it doesn't match at least one account, then it requires a foreign signature.
    if (!matchesOneAccount) return true;
  }

  return false;
};
