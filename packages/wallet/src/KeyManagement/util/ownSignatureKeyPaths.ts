import { AccountKeyDerivationPath, GroupedAddress, KeyRole } from '../types';
import { Cardano } from '@cardano-sdk/core';
import { InputResolver } from '../../services';
import { isNotNil } from '@cardano-sdk/util';
import uniq from 'lodash/uniq';

/**
 * Assumes that a single staking key is used for all addresses (index=0)
 *
 * @returns {AccountKeyDerivationPath[]} derivation paths for keys to sign transaction with
 */
export const ownSignatureKeyPaths = async (
  txBody: Cardano.NewTxBodyAlonzo,
  knownAddresses: GroupedAddress[],
  inputResolver: InputResolver
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

  const isStakingKeySignatureRequired = txBody.certificates?.length;
  if (isStakingKeySignatureRequired) {
    return [...paymentKeyPaths, { index: 0, role: KeyRole.Stake }];
  }
  return paymentKeyPaths;
};
