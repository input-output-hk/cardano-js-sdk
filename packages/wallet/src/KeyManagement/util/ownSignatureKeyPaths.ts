import { Cardano, util } from '@cardano-sdk/core';
import { GroupedAddress, KeyType } from '../types';
import { uniq } from 'lodash-es';

export interface PartialDerivationPath {
  role: KeyType;
  index: number;
}

/**
 * Assumes that a single staking key is used for all addresses (index=0)
 *
 * @returns {PartialDerivationPath[]} derivation paths for keys to sign transaction with
 */
export const ownSignatureKeyPaths = (
  txBody: Cardano.TxBodyAlonzo,
  knownAddresses: GroupedAddress[]
): PartialDerivationPath[] => {
  const paymentKeyPaths = uniq(
    txBody.inputs.map((input) => knownAddresses.find(({ address }) => address === input.address)).filter(util.isNotNil)
  ).map(({ type, index }) => ({ index, role: Number(type) }));
  const isStakingKeySignatureRequired = txBody.certificates?.length;
  if (isStakingKeySignatureRequired) {
    return [...paymentKeyPaths, { index: 0, role: KeyType.Stake }];
  }
  return paymentKeyPaths;
};
