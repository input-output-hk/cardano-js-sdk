import { Cardano } from '@cardano-sdk/core';
import { ChainSyncEventType, Mappers, ProjectionEvent } from '@cardano-sdk/projection';
import { GovernanceActionEntity } from '../entity';
import { typeormOperator } from './util';

export const willStoreGovernanceAction = (evt: ProjectionEvent<Mappers.WithGovernanceActions>) =>
  evt.governanceActions.length > 0;

export const storeGovernanceAction = typeormOperator<Mappers.WithGovernanceActions>(async (evt) => {
  if (evt.eventType === ChainSyncEventType.RollBackward || !willStoreGovernanceAction(evt)) return;

  const { governanceActions, queryRunner } = evt;
  const repository = queryRunner.manager.getRepository(GovernanceActionEntity);

  for (const { action, index, slot } of governanceActions) {
    const { anchor, deposit, governanceAction, rewardAccount } = action;
    const { actionIndex, id } = index;
    const actionEntity = repository.create({
      action: governanceAction,
      anchorHash: anchor.dataHash,
      anchorUrl: anchor.url,
      block: { slot },
      deposit,
      index: actionIndex,
      stakeCredentialHash: Cardano.Address.fromString(rewardAccount)!.asReward()!.getPaymentCredential().hash,
      txId: id
    });

    await repository.insert(actionEntity);
  }
});
