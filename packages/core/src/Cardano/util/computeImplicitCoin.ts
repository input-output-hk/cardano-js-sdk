/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable complexity */
import { BigIntMath } from '@cardano-sdk/util';
import { Cardano } from '../..';
import { HydratedTxBody, Lovelace } from '../types';

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

const stakeCredentialInRewardAccounts = (
  stakeCredential: Cardano.Credential,
  rewardAccounts: Cardano.RewardAccount[]
): boolean => {
  // No reward accounts means accept any stake credential
  if (rewardAccounts.length === 0) return true;
  const networkId = Cardano.RewardAccount.toNetworkId(rewardAccounts[0]);
  return rewardAccounts.includes(Cardano.RewardAccount.fromCredential(stakeCredential, networkId));
};

const computeShellyDeposits = (
  depositParams: DepositProtocolParams,
  certificates: Cardano.Certificate[],
  rewardAccounts: Cardano.RewardAccount[]
): { deposit: Cardano.Lovelace; reclaimDeposit: Cardano.Lovelace } => {
  let deposit = 0n;
  let reclaimDeposit = 0n;
  const anyRewardAccount = rewardAccounts.length === 0;

  const poolIds = new Set(
    rewardAccounts.map((account) => Cardano.PoolId.fromKeyHash(Cardano.RewardAccount.toHash(account)))
  );

  // TODO: For the case of deregistration (StakeDeregistration and PoolRetirement) the code here is not entirely correct
  // as we are assuming the current protocol parameters for the deposits where the same as the ones used when the certificates where issued.
  // This is going to work for now, but to properly implement this we need a way to know when the certificate we are undoing was originally issued
  // and get the protocol parameters for that epoch. However, these parameters in particular have never change in mainnet, so this is probably
  // is good for now.
  for (const cert of certificates) {
    switch (cert.__typename) {
      case Cardano.CertificateType.StakeRegistration:
        if (stakeCredentialInRewardAccounts(cert.stakeCredential, rewardAccounts))
          deposit += depositParams.stakeKeyDeposit;
        break;
      case Cardano.CertificateType.StakeDeregistration:
        if (stakeCredentialInRewardAccounts(cert.stakeCredential, rewardAccounts))
          reclaimDeposit += depositParams.stakeKeyDeposit;
        break;
      case Cardano.CertificateType.PoolRegistration:
        if (anyRewardAccount || rewardAccounts.some((acct) => cert.poolParameters.owners.includes(acct)))
          deposit += depositParams.poolDeposit;
        break;
      case Cardano.CertificateType.PoolRetirement: {
        if (anyRewardAccount || poolIds.has(cert.poolId)) reclaimDeposit += depositParams.poolDeposit;
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
  rewardAccounts: Cardano.RewardAccount[]
): { deposit: Cardano.Lovelace; reclaimDeposit: Cardano.Lovelace } => {
  let deposit = 0n;
  let reclaimDeposit = 0n;

  for (const cert of certificates) {
    switch (cert.__typename) {
      case Cardano.CertificateType.Registration:
      case Cardano.CertificateType.StakeRegistrationDelegation:
      case Cardano.CertificateType.VoteRegistrationDelegation:
      case Cardano.CertificateType.StakeVoteRegistrationDelegation:
        if (stakeCredentialInRewardAccounts(cert.stakeCredential, rewardAccounts)) deposit += cert.deposit;
        break;
      case Cardano.CertificateType.Unregistration:
        if (stakeCredentialInRewardAccounts(cert.stakeCredential, rewardAccounts)) reclaimDeposit += cert.deposit;
        break;
    }
  }

  return {
    deposit,
    reclaimDeposit
  };
};

/** Inspects a transaction for its deposits and returned deposits. */
const getTxDeposits = (
  { stakeKeyDeposit, poolDeposit }: Pick<Cardano.ProtocolParameters, 'stakeKeyDeposit' | 'poolDeposit'>,
  certificates: Cardano.Certificate[],
  rewardAccounts: Cardano.RewardAccount[] = []
): { deposit: Cardano.Lovelace; reclaimDeposit: Cardano.Lovelace } => {
  if (certificates.length === 0) return { deposit: 0n, reclaimDeposit: 0n };

  const depositParams = {
    poolDeposit: poolDeposit ? BigInt(poolDeposit) : 0n,
    stakeKeyDeposit: BigInt(stakeKeyDeposit)
  };

  const shelleyDeposits = computeShellyDeposits(depositParams, certificates, rewardAccounts);
  const conwayDeposits = computeConwayDeposits(certificates, rewardAccounts);

  return {
    deposit: shelleyDeposits.deposit + conwayDeposits.deposit,
    reclaimDeposit: shelleyDeposits.reclaimDeposit + conwayDeposits.reclaimDeposit
  };
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
  const { deposit, reclaimDeposit } = getTxDeposits(
    { poolDeposit, stakeKeyDeposit },
    certificates ?? [],
    rewardAccounts
  );

  const withdrawalsTotal = (withdrawals && BigIntMath.sum(withdrawals.map(({ quantity }) => quantity))) || 0n;

  return {
    deposit,
    input: withdrawalsTotal + reclaimDeposit,
    reclaimDeposit,
    withdrawals: withdrawalsTotal
  };
};
