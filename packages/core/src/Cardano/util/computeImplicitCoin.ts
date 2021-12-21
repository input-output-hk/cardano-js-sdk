import { BigIntMath, Cardano, ProtocolParametersRequiredByWallet } from '../../';

/**
 * Implementation is the same as in CSL.get_implicit_input() and CSL.get_deposit().
 */
export const computeImplicitCoin = (
  { stakeKeyDeposit, poolDeposit }: Pick<ProtocolParametersRequiredByWallet, 'stakeKeyDeposit' | 'poolDeposit'>,
  { certificates, withdrawals }: Pick<Cardano.TxBodyAlonzo, 'certificates' | 'withdrawals'>
): Cardano.ImplicitCoin => {
  const stakeKeyDepositBigint = stakeKeyDeposit && BigInt(stakeKeyDeposit);
  const poolDepositBigint = poolDeposit && BigInt(poolDeposit);
  const deposit = BigIntMath.sum(
    certificates?.map(
      (cert) =>
        (cert.__typename === Cardano.CertificateType.StakeKeyRegistration && stakeKeyDepositBigint) ||
        (cert.__typename === Cardano.CertificateType.PoolRegistration && poolDepositBigint) ||
        0n
    ) || []
  );
  const withdrawalsTotal = (withdrawals && BigIntMath.sum(withdrawals.map(({ quantity }) => quantity))) || 0n;
  const reclaimTotal = BigIntMath.sum(
    certificates?.map(
      (cert) =>
        (cert.__typename === Cardano.CertificateType.StakeKeyDeregistration && stakeKeyDepositBigint) ||
        (cert.__typename === Cardano.CertificateType.PoolRetirement && poolDepositBigint) ||
        0n
    ) || []
  );
  return {
    deposit,
    input: withdrawalsTotal + reclaimTotal
  };
};
