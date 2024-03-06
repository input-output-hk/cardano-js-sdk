/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable complexity */
import * as Crypto from '@cardano-sdk/crypto';
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
  rewardAccounts: Cardano.RewardAccount[],
  dRepKeyHash?: Crypto.Ed25519KeyHashHex,
  proposalProcedures?: Cardano.ProposalProcedure[]
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
      case Cardano.CertificateType.RegisterDelegateRepresentative:
      case Cardano.CertificateType.UnregisterDelegateRepresentative:
        if (
          !dRepKeyHash ||
          (cert.dRepCredential.type === Cardano.CredentialType.KeyHash &&
            cert.dRepCredential.hash === Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(dRepKeyHash))
        ) {
          cert.__typename === Cardano.CertificateType.RegisterDelegateRepresentative
            ? (deposit += cert.deposit)
            : (reclaimDeposit += cert.deposit);
        }
        break;
    }
  }

  if (proposalProcedures) for (const proposal of proposalProcedures) deposit += proposal.deposit;

  return {
    deposit,
    reclaimDeposit
  };
};

/** Inspects a transaction for its deposits and returned deposits. */
const getTxDeposits = (
  { stakeKeyDeposit, poolDeposit }: Pick<Cardano.ProtocolParameters, 'stakeKeyDeposit' | 'poolDeposit'>,
  certificates: Cardano.Certificate[],
  rewardAccounts: Cardano.RewardAccount[] = [],
  dRepKeyHash?: Crypto.Ed25519KeyHashHex,
  proposalProcedures?: Cardano.ProposalProcedure[]
): { deposit: Cardano.Lovelace; reclaimDeposit: Cardano.Lovelace } => {
  if (certificates.length === 0 && (!proposalProcedures || proposalProcedures.length === 0))
    return { deposit: 0n, reclaimDeposit: 0n };

  const depositParams = {
    poolDeposit: poolDeposit ? BigInt(poolDeposit) : 0n,
    stakeKeyDeposit: BigInt(stakeKeyDeposit)
  };

  const shelleyDeposits = computeShellyDeposits(depositParams, certificates, rewardAccounts);
  const conwayDeposits = computeConwayDeposits(certificates, rewardAccounts, dRepKeyHash, proposalProcedures);

  return {
    deposit: shelleyDeposits.deposit + conwayDeposits.deposit,
    reclaimDeposit: shelleyDeposits.reclaimDeposit + conwayDeposits.reclaimDeposit
  };
};

/**
 * Computes the implicit coin from the given transaction.
 * If rewardAccounts is provided, it will only count the deposits from
 * Certificates that belong to any of the reward accounts provided.
 * If dRepKeyHash is provided, it will only count the deposits from Certificates
 * that belong to the given dRep.
 *
 * Is used by the input selector, and by the util to compute transaction summary/display.
 * The input selector doesn't filter by reward accounts because we are building the transaction
 * internally, so we know all the certificates are ours.
 * On the other hand, the transaction summary/display could receive a transaction from a dApp,
 * and can have mixed certificates (foreign and ours), so we need the list of reward accounts and drepKeyHash
 * to be able to distinguish the deposits that are going to our rewardAccounts from the ones that could
 * potentially go to a different reward accounts that we don't control (same with reclaims).
 */
export const computeImplicitCoin = (
  { stakeKeyDeposit, poolDeposit }: Pick<Cardano.ProtocolParameters, 'stakeKeyDeposit' | 'poolDeposit'>,
  {
    certificates,
    proposalProcedures,
    withdrawals
  }: Pick<HydratedTxBody, 'certificates' | 'proposalProcedures' | 'withdrawals'>,
  rewardAccounts?: Cardano.RewardAccount[],
  dRepKeyHash?: Crypto.Ed25519KeyHashHex
): ImplicitCoin => {
  const { deposit, reclaimDeposit } = getTxDeposits(
    { poolDeposit, stakeKeyDeposit },
    certificates ?? [],
    rewardAccounts,
    dRepKeyHash,
    proposalProcedures
  );

  const withdrawalsTotal = (withdrawals && BigIntMath.sum(withdrawals.map(({ quantity }) => quantity))) || 0n;

  return {
    deposit,
    input: withdrawalsTotal + reclaimDeposit,
    reclaimDeposit,
    withdrawals: withdrawalsTotal
  };
};
