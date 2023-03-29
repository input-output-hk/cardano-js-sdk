import * as Crypto from '@cardano-sdk/crypto';
import { DataSource, QueryRunner } from 'typeorm';
import { GranularSinkEvent, Operators, Projections } from '@cardano-sdk/projection';
import { StakeKeyEntity } from '../../src';
import { WithTypeormContext } from '../../src/types';
import { firstValueFrom, of } from 'rxjs';
import { initializeDataSource } from '../util';
import { stakeKeys } from '../../src/sinks';

describe('sinks/stakeKeys', () => {
  let dataSource: DataSource;
  let queryRunner: QueryRunner;

  const processEvent = (projectedStakeKeys: Pick<Operators.WithStakeKeys['stakeKeys'], 'insert' | 'del'>) =>
    firstValueFrom(
      of({
        queryRunner,
        stakeKeys: projectedStakeKeys
      } as GranularSinkEvent<'stakeKeys', WithTypeormContext>).pipe(stakeKeys.sink$)
    );

  beforeEach(async () => {
    dataSource = await initializeDataSource({ stakeKeys: Projections.stakeKeys });
    queryRunner = dataSource.createQueryRunner();
  });

  afterEach(async () => {
    await queryRunner.release();
    await dataSource.destroy();
  });

  it('inserts and deletes rows based on event', async () => {
    await processEvent({
      del: [] as Crypto.Ed25519KeyHashHex[],
      insert: [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')]
    });
    expect(await queryRunner.manager.count(StakeKeyEntity)).toBe(1);
    await processEvent({
      del: [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')],
      insert: [] as Crypto.Ed25519KeyHashHex[]
    });
    expect(await queryRunner.manager.count(StakeKeyEntity)).toBe(0);
  });
});
