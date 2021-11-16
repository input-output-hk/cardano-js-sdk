import { BigIntMath, Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { InitializeTxProps } from '../types';

/**
 * Implementation is the same as in CSL.get_implicit_input() and CSL.get_deposit().
 */
export const computeImplicitCoin = (
  { stakeKeyDeposit, poolDeposit }: ProtocolParametersRequiredByWallet,
  { certificates, withdrawals }: Pick<InitializeTxProps, 'certificates' | 'withdrawals'>
): Cardano.ImplicitCoin => {
  const stakeKeyDepositBigint = stakeKeyDeposit && BigInt(stakeKeyDeposit);
  const poolDepositBigint = poolDeposit && BigInt(poolDeposit);
  const deposit = BigIntMath.sum(
    certificates?.map(
      (cert) =>
        (cert.__typename === Cardano.CertificateType.StakeRegistration && stakeKeyDepositBigint) ||
        (cert.__typename === Cardano.CertificateType.PoolRegistration && poolDepositBigint) ||
        0n
    ) || []
  );
  const withdrawalsTotal = (withdrawals && BigIntMath.sum(withdrawals.map(({ quantity }) => quantity))) || 0n;
  const reclaimTotal = BigIntMath.sum(
    certificates?.map(
      (cert) =>
        (cert.__typename === Cardano.CertificateType.StakeDeregistration && stakeKeyDepositBigint) ||
        (cert.__typename === Cardano.CertificateType.PoolRetirement && poolDepositBigint) ||
        0n
    ) || []
  );
  return {
    deposit,
    input: withdrawalsTotal + reclaimTotal
  };
};
