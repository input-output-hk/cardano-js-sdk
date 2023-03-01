import { AccountKeyDerivationPath, GroupedAddress } from '../types';
import { Cardano } from '@cardano-sdk/core';
import { isNotNil } from '@cardano-sdk/util';
import uniq from 'lodash/uniq';
import uniqBy from 'lodash/uniqBy';

/**
 * Gets whether any certificate in the provided certificate list requires a stake key signature.
 *
 * @param groupedAddresses The known grouped addresses.
 * @param txBody The transaction body.
 */
// eslint-disable-next-line complexity
const getStakingKeyPaths = (
  groupedAddresses: GroupedAddress[],
  txBody: Cardano.TxBody
  // eslint-disable-next-line sonarjs/cognitive-complexity
) => {
  const paths: Set<AccountKeyDerivationPath> = new Set();
  const uniqueAccounts = uniqBy(groupedAddresses, 'rewardAccount');

  for (const account of uniqueAccounts) {
    const stakeKeyHash = Cardano.RewardAccount.toHash(account.rewardAccount);
    const poolId = Cardano.PoolId.fromKeyHash(stakeKeyHash);

    if (!account.stakeKeyDerivationPath) continue;

    if (txBody.withdrawals?.some((withdrawal) => account.rewardAccount === withdrawal.stakeAddress))
      paths.add(account.stakeKeyDerivationPath);

    if (!txBody.certificates) continue;

    for (const certificate of txBody.certificates) {
      switch (certificate.__typename) {
        case Cardano.CertificateType.StakeKeyDeregistration:
        case Cardano.CertificateType.StakeDelegation:
          if (certificate.stakeKeyHash === stakeKeyHash) paths.add(account.stakeKeyDerivationPath);
          break;
        case Cardano.CertificateType.PoolRegistration:
          for (const owner of certificate.poolParameters.owners) {
            // eslint-disable-next-line max-depth
            if (owner === account.rewardAccount) paths.add(account.stakeKeyDerivationPath);
          }
          break;
        case Cardano.CertificateType.PoolRetirement:
          if (certificate.poolId === poolId) paths.add(account.stakeKeyDerivationPath);
          break;
        case Cardano.CertificateType.MIR:
          if (certificate.rewardAccount === account.rewardAccount) paths.add(account.stakeKeyDerivationPath);
          break;
        case Cardano.CertificateType.StakeKeyRegistration:
        case Cardano.CertificateType.GenesisKeyDelegation:
        default:
        // Nothing to do.
      }
    }
  }

  return paths;
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

  return [...paymentKeyPaths, ...getStakingKeyPaths(knownAddresses, txBody)];
};
