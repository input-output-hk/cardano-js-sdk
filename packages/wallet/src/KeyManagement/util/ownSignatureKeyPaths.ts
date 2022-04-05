import { AccountKeyDerivationPath, GroupedAddress, InputAddressResolver, KeyRole } from '../types';
import { Cardano, util } from '@cardano-sdk/core';
import { uniq } from 'lodash-es';

/**
 * Assumes that a single staking key is used for all addresses (index=0)
 *
 * @returns {AccountKeyDerivationPath[]} derivation paths for keys to sign transaction with
 */
export const ownSignatureKeyPaths = (
  txBody: Cardano.NewTxBodyAlonzo,
  knownAddresses: GroupedAddress[],
  resolveInputAddress: InputAddressResolver
): AccountKeyDerivationPath[] => {
  const paymentKeyPaths = uniq(
    txBody.inputs
      .map((input) => {
        const ownAddress = resolveInputAddress(input);
        if (!ownAddress) return null;
        return knownAddresses.find(({ address }) => address === ownAddress);
      })
      .filter(util.isNotNil)
  ).map(({ type, index }) => ({ index, role: Number(type) }));
  const isStakingKeySignatureRequired = txBody.certificates?.length;
  if (isStakingKeySignatureRequired) {
    return [...paymentKeyPaths, { index: 0, role: KeyRole.Stake }];
  }
  return paymentKeyPaths;
};
