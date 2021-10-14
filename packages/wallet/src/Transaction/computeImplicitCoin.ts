import { ImplicitCoin } from '@cardano-sdk/cip2';
import { BigIntMath, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { InitializeTxProps } from './types';

/**
 * Implementation is the same as in csl.get_implicit_input() and csl.get_deposit().
 */
export const computeImplicitCoin = (
  { stakeKeyDeposit, poolDeposit }: ProtocolParametersRequiredByWallet,
  { certificates, withdrawals }: InitializeTxProps
): ImplicitCoin => {
  const stakeKeyDepositBigint = stakeKeyDeposit && BigInt(stakeKeyDeposit);
  const poolDepositBigint = poolDeposit && BigInt(poolDeposit);
  const deposit = BigIntMath.sum(
    certificates?.map(
      (cert) =>
        (cert.as_stake_registration() && stakeKeyDepositBigint) ||
        (cert.as_pool_registration() && poolDepositBigint) ||
        0n
    ) || []
  );
  const withdrawalsTotal =
    (withdrawals && BigIntMath.sum(withdrawals.map(({ quantity }) => BigInt(quantity.to_str())))) || 0n;
  const reclaimTotal = BigIntMath.sum(
    certificates?.map(
      (cert) =>
        (cert.as_stake_deregistration() && stakeKeyDepositBigint) ||
        (cert.as_pool_retirement() && poolDepositBigint) ||
        0n
    ) || []
  );
  return {
    deposit,
    input: withdrawalsTotal + reclaimTotal
  };
};
