import * as Crypto from '@cardano-sdk/crypto';
import { DataSource, QueryRunner } from 'typeorm';
import { Mappers, ProjectionEvent } from '@cardano-sdk/projection';
import { StakeKeyEntity } from '../../src';
import { WithTypeormContext, storeStakeKeys } from '../../src/operators';
import { firstValueFrom, of } from 'rxjs';
import { initializeDataSource } from '../util';

describe('storeStakeKeys', () => {
  let dataSource: DataSource;
  let queryRunner: QueryRunner;

  const processEvent = (projectedStakeKeys: Pick<Mappers.WithStakeKeys['stakeKeys'], 'insert' | 'del'>) =>
    firstValueFrom(
      of({
        queryRunner,
        stakeKeys: projectedStakeKeys
      } as ProjectionEvent<Mappers.WithStakeKeys & WithTypeormContext>).pipe(storeStakeKeys())
    );

  beforeEach(async () => {
    dataSource = await initializeDataSource({ entities: [StakeKeyEntity] });
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
