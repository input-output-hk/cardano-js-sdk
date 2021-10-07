import { ImplicitCoin } from '@cardano-sdk/cip2';
import { ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { sum } from 'lodash-es';
import { InitializeTxProps } from '../types';

/**
 * Implementation is the same as in csl.get_implicit_input() and csl.get_deposit().
 * Alternatively could build transaction body and use CSL to compute these.
 * TODO: change lodash.sum to BigIntMath.sum when Lovelace type is aliased to bigint
 */
export const computeImplicitCoin = (
  { stakeKeyDeposit, poolDeposit }: ProtocolParametersRequiredByWallet,
  { certificates, withdrawals }: InitializeTxProps
): ImplicitCoin => {
  const deposit = sum(
    certificates?.map(
      (cert) => (cert.as_stake_registration() && stakeKeyDeposit) || (cert.as_pool_registration() && poolDeposit) || 0
    ) || []
  );
  const withdrawalsTotal =
    (withdrawals && sum(withdrawals.map(({ quantity }) => Number.parseInt(quantity.to_str())))) || 0;
  const refundTotal = sum(
    certificates?.map(
      (cert) => (cert.as_stake_deregistration() && stakeKeyDeposit) || (cert.as_pool_retirement() && poolDeposit) || 0
    ) || []
  );
  return {
    deposit,
    input: withdrawalsTotal + refundTotal
  };
};
