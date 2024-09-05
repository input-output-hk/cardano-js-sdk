import { BlockEntity, GovernanceActionEntity } from '../../src';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { DataSource, QueryRunner } from 'typeorm';
import { Mappers, ProjectionEvent } from '@cardano-sdk/projection';
import { WithTypeormContext, storeBlock, storeGovernanceAction } from '../../src/operators';
import { firstValueFrom, of } from 'rxjs';
import { initializeDataSource } from '../util';

describe('storeGovernanceAction', () => {
  let dataSource: DataSource;
  let queryRunner: QueryRunner;

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

  const processEvent = () => {
    const anchor = {
      dataHash: '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d',
      url: 'https://testing.this'
    };
    const deposit = 1_000_000n;
    // cSpell:disable-next-line
    const rewardAccount = 'stake_test1urc4mvzl2cp4gedl3yq2px7659krmzuzgnl2dpjjgsydmqqxgamj7';

    const proposal = { anchor, deposit, rewardAccount };

    const tx = {
      body: { proposalProcedures: proposals.map((action) => ({ ...proposal, governanceAction: action })) },
      id: '5de144891eb542ef71ac75dec2265cfd0a292c8a3eb35c16591d9a7b865f48e5'
    };
    const evt = {
      block: {
        body: [tx],
        header: { blockNo: 467, hash: '69fff584eb85e83d7decd97331310b59f087a4e648555c5d1f65c6d62ff4cc45', slot: 4984 }
      },
      eventType: ChainSyncEventType.RollForward,
      queryRunner
    } as unknown as ProjectionEvent<WithTypeormContext>;

    return firstValueFrom(of(evt).pipe(Mappers.withGovernanceActions(), storeBlock(), storeGovernanceAction()));
  };

  beforeEach(async () => {
    dataSource = await initializeDataSource({ entities: [BlockEntity, GovernanceActionEntity] });
    queryRunner = dataSource.createQueryRunner();
  });

  afterEach(async () => {
    await queryRunner.release();
    await dataSource.destroy();
  });

  it('inserts governance action proposals', async () => {
    await processEvent();

    expect(await queryRunner.manager.count(GovernanceActionEntity)).toBe(3);

    const savedActions = await queryRunner.manager.getRepository(GovernanceActionEntity).find();

    for (const { action, index } of savedActions) expect(action).toEqual(proposals[index!]);
  });
});
