import { AccountKeyDerivationPath, GroupedAddress, KeyRole } from '../types';
import { Cardano } from '@cardano-sdk/core';
import { isNotNil } from '@cardano-sdk/util';
import uniq from 'lodash/uniq';

/**
 * Gets whether any certificate in the provided certificate list requires a stake key signature.
 *
 * @param rewardAccounts The known reward accounts.
 * @param certificates The list of certificates.
 */
// eslint-disable-next-line complexity
const isStakingKeySignatureRequired = (
  rewardAccounts: Cardano.RewardAccount[],
  certificates: Cardano.Certificate[] | undefined
  // eslint-disable-next-line sonarjs/cognitive-complexity
) => {
  if (!certificates?.length) return false;
  if (!rewardAccounts?.length) return false;

  for (const account of rewardAccounts) {
    const stakeKeyHash = Cardano.Ed25519KeyHash.fromRewardAccount(account);
    const poolId = Cardano.PoolId.fromKeyHash(stakeKeyHash);

    for (const certificate of certificates) {
      switch (certificate.__typename) {
        case Cardano.CertificateType.StakeKeyRegistration:
        case Cardano.CertificateType.StakeKeyDeregistration:
        case Cardano.CertificateType.StakeDelegation:
          if (certificate.stakeKeyHash === stakeKeyHash) return true;
          break;
        case Cardano.CertificateType.PoolRegistration:
          // eslint-disable-next-line max-depth
          for (const owner of certificate.poolParameters.owners) if (owner === account) return true;
          break;
        case Cardano.CertificateType.PoolRetirement:
          if (certificate.poolId === poolId) return true;
          break;
        case Cardano.CertificateType.MIR:
          if (certificate.rewardAccount === account) return true;
          break;
        case Cardano.CertificateType.GenesisKeyDelegation:
        default:
        // Nothing to do.
      }
    }
  }

  return false;
};

/**
 * Assumes that a single staking key is used for all addresses (index=0)
 *
 * @returns {AccountKeyDerivationPath[]} derivation paths for keys to sign transaction with
 */
export const ownSignatureKeyPaths = async (
  txBody: Cardano.TxBody,
  knownAddresses: GroupedAddress[],
  inputResolver: Cardano.util.InputResolver
): Promise<AccountKeyDerivationPath[]> => {
  const paymentKeyPaths = uniq(
    (
      await Promise.all(
        txBody.inputs.map(async (input) => {
          const ownAddress = await inputResolver.resolveInputAddress(input);
          if (!ownAddress) return null;
          return knownAddresses.find(({ address }) => address === ownAddress);
        })
      )
    ).filter(isNotNil)
  ).map(({ type, index }) => ({ index, role: Number(type) }));

  const rewardAccounts = [...new Set(knownAddresses.map(({ rewardAccount }) => rewardAccount))];

  if (
    isStakingKeySignatureRequired(rewardAccounts, txBody.certificates) ||
    txBody.withdrawals?.some((withdrawal) => rewardAccounts.includes(withdrawal.stakeAddress))
  ) {
    return [...paymentKeyPaths, { index: 0, role: KeyRole.Stake }];
  }
  return paymentKeyPaths;
};
