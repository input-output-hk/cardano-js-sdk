import { MigrationInterface, QueryRunner } from 'typeorm';
import { PoolRewardsEntity } from '@cardano-sdk/projection-typeorm';

export class RewardsPledgeNumericMigration1715157190230 implements MigrationInterface {
  static entity = PoolRewardsEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'ALTER TABLE "pool_rewards" ALTER COLUMN "pledge" TYPE numeric(20,0) USING pledge::numeric'
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "pool_rewards" ALTER COLUMN "pledge" TYPE bigint USING pledge::bigint');
  }
}
