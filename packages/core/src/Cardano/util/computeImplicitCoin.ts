import { BigIntMath } from '@cardano-sdk/util';
import { Cardano } from '../..';
import { CertificateType, HydratedTxBody, Lovelace } from '../types';

/** Implicit coin quantities used in the transaction */
export interface ImplicitCoin {
  /** Reward withdrawals */
  withdrawals?: Lovelace;
  /** Reward withdrawals + deposit reclaims (total return) */
  input?: Lovelace;
  /** Delegation registration deposit */
  deposit?: Lovelace;
}

const stakeKeyRegistrationDepositCertificates = new Set([
  CertificateType.StakeRegistration,
  CertificateType.Registration,
  CertificateType.StakeRegistrationDelegation,
  CertificateType.VoteRegistrationDelegation,
  CertificateType.StakeVoteRegistrationDelegation
]);

/** Implementation is the same as in CSL.get_implicit_input() and CSL.get_deposit(). */
export const computeImplicitCoin = (
  {
    stakeKeyDeposit,
    poolDeposit,
    dRepDeposit
  }: Pick<Cardano.ProtocolParameters, 'stakeKeyDeposit' | 'poolDeposit' | 'dRepDeposit'>,
  { certificates, withdrawals }: Pick<HydratedTxBody, 'certificates' | 'withdrawals'>
): ImplicitCoin => {
  const stakeKeyDepositBigint = stakeKeyDeposit && BigInt(stakeKeyDeposit);
  const poolDepositBigint = poolDeposit && BigInt(poolDeposit);
  const drepDepositBigInt = dRepDeposit && BigInt(dRepDeposit);
  const deposit = BigIntMath.sum(
    certificates?.map(
      (cert) =>
        (stakeKeyRegistrationDepositCertificates.has(cert.__typename) && stakeKeyDepositBigint) ||
        (cert.__typename === CertificateType.PoolRegistration && poolDepositBigint) ||
        (cert.__typename === CertificateType.RegisterDelegateRepresentative && drepDepositBigInt) ||
        0n
    ) || []
  );
  const withdrawalsTotal = (withdrawals && BigIntMath.sum(withdrawals.map(({ quantity }) => quantity))) || 0n;
  const reclaimTotal = BigIntMath.sum(
    certificates?.map(
      (cert) =>
        (cert.__typename === CertificateType.StakeDeregistration && stakeKeyDepositBigint) ||
        (cert.__typename === CertificateType.Unregistration && stakeKeyDepositBigint) ||
        (cert.__typename === CertificateType.PoolRetirement && poolDepositBigint) ||
        (cert.__typename === CertificateType.UnregisterDelegateRepresentative && drepDepositBigInt) ||
        0n
    ) || []
  );
  return {
    deposit,
    input: withdrawalsTotal + reclaimTotal,
    withdrawals: withdrawalsTotal
  };
};
