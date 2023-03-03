import * as Crypto from '@cardano-sdk/crypto';
import { DataSource, QueryRunner } from 'typeorm';
import { Operators, Projections } from '@cardano-sdk/projection';
import { SinkEventType } from './types';
import { StakeKeyEntity } from '../../src';
import { firstValueFrom } from 'rxjs';
import { initializeDataSource } from '../connection';
import { stakeKeys } from '../../src/sinks';

describe('sinks/stakeKeys', () => {
  let dataSource: DataSource;
  let queryRunner: QueryRunner;

  const processEvent = (projectedStakeKeys: Pick<Operators.WithStakeKeys['stakeKeys'], 'insert' | 'del'>) =>
    firstValueFrom(
      stakeKeys.sink({
        queryRunner,
        stakeKeys: projectedStakeKeys
      } as SinkEventType<typeof stakeKeys>)
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
