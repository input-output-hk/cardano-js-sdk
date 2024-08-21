import { Cardano } from '@cardano-sdk/core';
import { unifiedProjectorOperator } from '../utils';

export type WithGovernanceActions = {
  governanceActions: {
    action: Cardano.ProposalProcedure;
    index: Cardano.GovernanceActionId;
    // LW-11270
    // This is required to handle rollbacks, once we have transactions projection this could be removed
    slot: Cardano.Slot;
  }[];
};

export const withGovernanceActions = unifiedProjectorOperator<{}, WithGovernanceActions>((evt) => {
  const { body, header } = evt.block;
  const governanceActions: WithGovernanceActions['governanceActions'] = [];

  for (const tx of body)
    if (tx.body.proposalProcedures)
      for (const [actionIndex, action] of tx.body.proposalProcedures.entries())
        governanceActions.push({ action, index: { actionIndex, id: tx.id }, slot: header.slot });

  return { ...evt, governanceActions };
});
