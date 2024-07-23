import { Cardano } from '@cardano-sdk/core';
import { Mappers, ProjectionEvent } from '../../../src';
import { firstValueFrom, of } from 'rxjs';
import { toSerializableObject } from '@cardano-sdk/util';

describe('withGovernanceActions', () => {
  const anchor = {
    dataHash: '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d',
    url: 'https://testing.this'
  };
  const deposit = 1_000_000n;
  // cSpell:disable-next-line
  const rewardAccount = 'stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7';

  const proposal = { anchor, deposit, rewardAccount };

  const proposals = [
    {
      __typename: Cardano.GovernanceActionType.hard_fork_initiation_action,
      governanceActionId: null,
      protocolVersion: { major: 11, minor: 0 }
    },
    { __typename: Cardano.GovernanceActionType.info_action },
    {
      __typename: Cardano.GovernanceActionType.parameter_change_action,
      governanceActionId: null,
      policyHash: null,
      protocolParamUpdate: { maxBlockHeaderSize: 500, maxCollateralInputs: 100 }
    }
  ] as const;

  const txId1 = '5de144891eb542ef71ac75dec2265cfd0a292c8a3eb35c16591d9a7b865f48e5';
  const txId2 = '5de144891eb542ef71ac75dec2265cfd0a292c8a3eb35c16591d9a7b865f48e6';

  const source$ = of({
    block: {
      body: [
        {
          body: {
            proposalProcedures: [
              { ...proposal, governanceAction: proposals[0] },
              { ...proposal, governanceAction: proposals[2] }
            ]
          },
          id: txId1
        },
        {
          body: { proposalProcedures: [{ ...proposal, governanceAction: proposals[1] }] },
          id: txId2
        }
      ],
      header: { slot: 4984 }
    }
  } as ProjectionEvent);

  it('maps all governance actions into a flat array', async () => {
    const { governanceActions } = await firstValueFrom(source$.pipe(Mappers.withGovernanceActions()));
    expect(toSerializableObject(governanceActions)).toEqual(
      toSerializableObject([
        { action: { ...proposal, governanceAction: proposals[0] }, index: { actionIndex: 0, id: txId1 }, slot: 4984 },
        { action: { ...proposal, governanceAction: proposals[2] }, index: { actionIndex: 1, id: txId1 }, slot: 4984 },
        { action: { ...proposal, governanceAction: proposals[1] }, index: { actionIndex: 0, id: txId2 }, slot: 4984 }
      ])
    );
  });
});
