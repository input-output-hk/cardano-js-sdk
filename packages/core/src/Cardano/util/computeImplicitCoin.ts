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
  /** Deposits returned */
  reclaimDeposit?: Lovelace;
}

type DepositProtocolParams = { stakeKeyDeposit: Cardano.Lovelace; poolDeposit: Cardano.Lovelace };

const computeShellyDeposits = (
  depositParams: DepositProtocolParams,
  certificates: Cardano.Certificate[],
  rewardAccounts: Cardano.RewardAccount[],
  poolIds: Set<Cardano.PoolId>,
  networkId: Cardano.NetworkId
): { deposit: Cardano.Lovelace; reclaimDeposit: Cardano.Lovelace } => {
  let deposit = 0n;
  let reclaimDeposit = 0n;

  // TODO: For the case of deregistration (StakeDeregistration and PoolRetirement) the code here is not entirely correct
  // as we are assuming the current protocol parameters for the deposits where the same as the ones used when the certificates where issued.
  // This is going to work for now, but to properly implement this we need a way to know when the certificate we are undoing was originally issued
  // and get the protocol parameters for that epoch. However, these parameters in particular have never change in mainnet, so this is probably
  // is good for now.
  for (const cert of certificates) {
    switch (cert.__typename) {
      case Cardano.CertificateType.StakeRegistration:
        if (rewardAccounts.includes(Cardano.RewardAccount.fromCredential(cert.stakeCredential, networkId)))
          deposit += depositParams.stakeKeyDeposit;
        break;
      case Cardano.CertificateType.StakeDeregistration:
        if (rewardAccounts.includes(Cardano.RewardAccount.fromCredential(cert.stakeCredential, networkId)))
          reclaimDeposit += depositParams.stakeKeyDeposit;
        break;
      case Cardano.CertificateType.PoolRegistration:
        if (rewardAccounts.some((acct) => cert.poolParameters.owners.includes(acct)))
          deposit += depositParams.poolDeposit;
        break;
      case Cardano.CertificateType.PoolRetirement: {
        if (poolIds.has(cert.poolId)) reclaimDeposit += depositParams.poolDeposit;
        break;
      }
    }
  }

  return {
    deposit,
    reclaimDeposit
  };
};

const computeConwayDeposits = (
  certificates: Cardano.Certificate[],
  rewardAccounts: Cardano.RewardAccount[],
  networkId: Cardano.NetworkId
): { deposit: Cardano.Lovelace; reclaimDeposit: Cardano.Lovelace } => {
  let deposit = 0n;
  let reclaimDeposit = 0n;

  for (const cert of certificates) {
    switch (cert.__typename) {
      case Cardano.CertificateType.Registration:
      case Cardano.CertificateType.StakeRegistrationDelegation:
      case Cardano.CertificateType.VoteRegistrationDelegation:
      case Cardano.CertificateType.StakeVoteRegistrationDelegation:
        if (rewardAccounts.includes(Cardano.RewardAccount.fromCredential(cert.stakeCredential, networkId)))
          deposit += cert.deposit;
        break;
      case Cardano.CertificateType.Unregistration:
        if (rewardAccounts.includes(Cardano.RewardAccount.fromCredential(cert.stakeCredential, networkId)))
          reclaimDeposit += cert.deposit;
        break;
    }
  }

  return {
    deposit,
    reclaimDeposit
  };
};

/** Inspects a transaction for its deposits and returned deposits. */
const getTxOwnDeposits = (
  { stakeKeyDeposit, poolDeposit }: Pick<Cardano.ProtocolParameters, 'stakeKeyDeposit' | 'poolDeposit'>,
  certificates: Cardano.Certificate[],
  rewardAccounts: Cardano.RewardAccount[]
): { deposit: Cardano.Lovelace; reclaimDeposit: Cardano.Lovelace } => {
  if (rewardAccounts.length === 0 || certificates.length === 0) return { deposit: 0n, reclaimDeposit: 0n };

  const poolIds = new Set(
    rewardAccounts
      .map((account) => Cardano.RewardAccount.toHash(account))
      .map((hash) => Cardano.PoolId.fromKeyHash(hash))
  );

  const networkId = Cardano.RewardAccount.toNetworkId(rewardAccounts[0]);

  const depositParams = {
    poolDeposit: poolDeposit ? BigInt(poolDeposit) : 0n,
    stakeKeyDeposit: BigInt(stakeKeyDeposit)
  };

  const shelleyDeposits = computeShellyDeposits(depositParams, certificates, rewardAccounts, poolIds, networkId);
  const conwayDeposits = computeConwayDeposits(certificates, rewardAccounts, networkId);

  return {
    deposit: shelleyDeposits.deposit + conwayDeposits.deposit,
    reclaimDeposit: shelleyDeposits.reclaimDeposit + conwayDeposits.reclaimDeposit
  };
};

const getTxDeposits = (
  { stakeKeyDeposit, poolDeposit }: Pick<Cardano.ProtocolParameters, 'stakeKeyDeposit' | 'poolDeposit'>,
  certificates: Cardano.Certificate[]
): { deposit: Lovelace; reclaimDeposit: Lovelace } => {
  const stakeKeyDepositBigint = stakeKeyDeposit && BigInt(stakeKeyDeposit);
  const poolDepositBigint = poolDeposit && BigInt(poolDeposit);
  const deposit = BigIntMath.sum(
    certificates.map(
      (cert) =>
        (cert.__typename === CertificateType.StakeRegistration && stakeKeyDepositBigint) ||
        (cert.__typename === CertificateType.PoolRegistration && poolDepositBigint) ||
        (cert.__typename === CertificateType.Unregistration && cert.deposit) ||
        0n
    ) || []
  );
  const reclaimTotal = BigIntMath.sum(
    certificates.map(
      // eslint-disable-next-line complexity
      (cert) =>
        (cert.__typename === CertificateType.StakeDeregistration && stakeKeyDepositBigint) ||
        (cert.__typename === CertificateType.PoolRetirement && poolDepositBigint) ||
        (cert.__typename === CertificateType.Registration && cert.deposit) ||
        (cert.__typename === CertificateType.StakeRegistrationDelegation && cert.deposit) ||
        (cert.__typename === CertificateType.VoteRegistrationDelegation && cert.deposit) ||
        (cert.__typename === CertificateType.StakeVoteRegistrationDelegation && cert.deposit) ||
        0n
    ) || []
  );

  return { deposit, reclaimDeposit: reclaimTotal };
};

/**
 * Computes the implicit coin from the given transaction.
 * If rewardAccounts is provided, it will only count the deposits from
 * Certificates that belong to any of the reward accounts provided.
 */
export const computeImplicitCoin = (
  { stakeKeyDeposit, poolDeposit }: Pick<Cardano.ProtocolParameters, 'stakeKeyDeposit' | 'poolDeposit'>,
  { certificates, withdrawals }: Pick<HydratedTxBody, 'certificates' | 'withdrawals'>,
  rewardAccounts?: Cardano.RewardAccount[]
): ImplicitCoin => {
  const { deposit, reclaimDeposit } = rewardAccounts
    ? getTxOwnDeposits({ poolDeposit, stakeKeyDeposit }, certificates ?? [], rewardAccounts)
    : getTxDeposits({ poolDeposit, stakeKeyDeposit }, certificates ?? []);

  const withdrawalsTotal = (withdrawals && BigIntMath.sum(withdrawals.map(({ quantity }) => quantity))) || 0n;

  return {
    deposit,
    input: withdrawalsTotal + reclaimDeposit,
    reclaimDeposit,
    withdrawals: withdrawalsTotal
  };
};
