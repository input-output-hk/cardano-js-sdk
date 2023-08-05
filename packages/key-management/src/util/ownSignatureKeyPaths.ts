import * as Crypto from '@cardano-sdk/crypto';
import { AccountKeyDerivationPath, GroupedAddress } from '../types';
import { Cardano } from '@cardano-sdk/core';
import { isNotNil } from '@cardano-sdk/util';
import isEqual from 'lodash/isEqual';
import uniq from 'lodash/uniq';
import uniqBy from 'lodash/uniqBy';
import uniqWith from 'lodash/uniqWith';

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
          if (
            certificate.kind === Cardano.MirCertificateKind.ToStakeCreds &&
            certificate.stakeCredential!.hash ===
              Crypto.Hash28ByteBase16(Cardano.RewardAccount.toHash(account.rewardAccount))
          )
            paths.add(account.stakeKeyDerivationPath);
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
 * Search for the key hashes provided in the requiredSigners in our current set of known addresses.
 *
 * @param groupedAddresses The known grouped addresses.
 * @param keyHashes The list of required signers key hashes (or undefined if none).
 * @returns A set of derivation paths if any of the key hashes is found.
 */
const getRequiredSignersKeyPaths = (
  groupedAddresses: GroupedAddress[],
  keyHashes?: Crypto.Ed25519KeyHashHex[]
): Set<AccountKeyDerivationPath> => {
  const paths: Set<AccountKeyDerivationPath> = new Set();

  if (!keyHashes) return paths;

  for (const keyHash of keyHashes) {
    for (const address of groupedAddresses) {
      const paymentCredential = Cardano.Address.fromBech32(address.address)?.asBase()?.getPaymentCredential().hash;
      const stakingCredential = Cardano.RewardAccount.toHash(address.rewardAccount);

      if (paymentCredential && paymentCredential.toString() === keyHash) {
        paths.add({ index: address.index, role: Number(address.type) });
      }

      if (stakingCredential && address.stakeKeyDerivationPath && stakingCredential.toString() === keyHash) {
        paths.add(address.stakeKeyDerivationPath);
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
  inputResolver: Cardano.InputResolver
): Promise<AccountKeyDerivationPath[]> => {
  const txInputs = [...txBody.inputs, ...(txBody.collaterals ? txBody.collaterals : [])];
  const paymentKeyPaths = uniq(
    (
      await Promise.all(
        txInputs.map(async (input) => {
          const resolution = await inputResolver.resolveInput(input);
          if (!resolution) return null;
          return knownAddresses.find(({ address }) => address === resolution.address);
        })
      )
    ).filter(isNotNil)
  ).map(({ type, index }) => ({ index, role: Number(type) }));

  return uniqWith(
    [
      ...paymentKeyPaths,
      ...getStakingKeyPaths(knownAddresses, txBody),
      ...getRequiredSignersKeyPaths(knownAddresses, txBody.requiredExtraSignatures)
    ],
    isEqual
  );
};
