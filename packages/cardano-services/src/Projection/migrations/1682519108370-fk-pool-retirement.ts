import { PoolRetirementEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class FkPoolRetirementMigration1682519108370 implements MigrationInterface {
  static entity = PoolRetirementEntity;

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'ALTER TABLE "pool_retirement" ADD CONSTRAINT "FK_pool_retirement_stake_pool_id" FOREIGN KEY ("stake_pool_id") REFERENCES "stake_pool"("id") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
    await queryRunner.query(
      'ALTER TABLE "stake_pool" ADD CONSTRAINT "FK_stake_pool_last_retirement_id" FOREIGN KEY ("last_retirement_id") REFERENCES "pool_retirement"("id") ON DELETE SET NULL ON UPDATE NO ACTION'
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "stake_pool" DROP CONSTRAINT "FK_stake_pool_last_retirement_id"');
    await queryRunner.query('ALTER TABLE "pool_retirement" DROP CONSTRAINT "FK_pool_retirement_stake_pool_id"');
  }
}
