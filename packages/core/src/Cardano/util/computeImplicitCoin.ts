import { BigIntMath } from '@cardano-sdk/util';
import { Cardano } from '../..';
import { CertificateType, Lovelace, TxBodyAlonzo } from '../types';

/**
 * Implicit coin quantities used in the transaction
 */
export interface ImplicitCoin {
  /**
   * Reward withdrawals + deposit reclaims
   */
  input?: Lovelace;
  /**
   * Delegation registration deposit
   */
  deposit?: Lovelace;
}

/**
 * Implementation is the same as in CSL.get_implicit_input() and CSL.get_deposit().
 */
export const computeImplicitCoin = (
  { stakeKeyDeposit, poolDeposit }: Pick<Cardano.ProtocolParameters, 'stakeKeyDeposit' | 'poolDeposit'>,
  { certificates, withdrawals }: Pick<TxBodyAlonzo, 'certificates' | 'withdrawals'>
): ImplicitCoin => {
  const stakeKeyDepositBigint = stakeKeyDeposit && BigInt(stakeKeyDeposit);
  const poolDepositBigint = poolDeposit && BigInt(poolDeposit);
  const deposit = BigIntMath.sum(
    certificates?.map(
      (cert) =>
        (cert.__typename === CertificateType.StakeKeyRegistration && stakeKeyDepositBigint) ||
        (cert.__typename === CertificateType.PoolRegistration && poolDepositBigint) ||
        0n
    ) || []
  );
  const withdrawalsTotal = (withdrawals && BigIntMath.sum(withdrawals.map(({ quantity }) => quantity))) || 0n;
  const reclaimTotal = BigIntMath.sum(
    certificates?.map(
      (cert) =>
        (cert.__typename === CertificateType.StakeKeyDeregistration && stakeKeyDepositBigint) ||
        (cert.__typename === CertificateType.PoolRetirement && poolDepositBigint) ||
        0n
    ) || []
  );
  return {
    deposit,
    input: withdrawalsTotal + reclaimTotal
  };
};
