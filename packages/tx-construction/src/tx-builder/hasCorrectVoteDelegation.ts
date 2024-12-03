import { Cardano } from '@cardano-sdk/core';
import { RewardAccountWithPoolId } from '../types';

export const hasCorrectVoteDelegation = ({
  dRepDelegatee
}: Pick<RewardAccountWithPoolId, 'dRepDelegatee'>): boolean => {
  const drep = dRepDelegatee?.delegateRepresentative;
  return !!drep && (!Cardano.isDrepInfo(drep) || drep.active);
};
