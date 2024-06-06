import * as Crypto from '@cardano-sdk/crypto';
import { StakeKeyEntity } from '../../src/index.js';
import { firstValueFrom, of } from 'rxjs';
import { initializeDataSource } from '../util.js';
import { storeStakeKeys } from '../../src/operators/index.js';
import type { DataSource, QueryRunner } from 'typeorm';
import type { Mappers, ProjectionEvent } from '@cardano-sdk/projection';
import type { WithTypeormContext } from '../../src/operators/index.js';

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
      del: [] as Crypto.Hash28ByteBase16[],
      insert: [Crypto.Hash28ByteBase16('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')]
    });
    expect(await queryRunner.manager.count(StakeKeyEntity)).toBe(1);
    await processEvent({
      del: [Crypto.Hash28ByteBase16('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')],
      insert: [] as Crypto.Hash28ByteBase16[]
    });
    expect(await queryRunner.manager.count(StakeKeyEntity)).toBe(0);
  });
});
