import { PoolRegistrationEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CostPledgeNumericMigration1689091319930 implements MigrationInterface {
  static entity = PoolRegistrationEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'ALTER TABLE "pool_registration" ALTER COLUMN "pledge" TYPE numeric(20,0) USING pledge::numeric'
    );
    await queryRunner.query(
      'ALTER TABLE "pool_registration" ALTER COLUMN "cost" TYPE numeric(20,0) USING cost::numeric'
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "pool_registration" ALTER COLUMN "cost" TYPE bigint USING cost::bigint');
    await queryRunner.query('ALTER TABLE "pool_registration" ALTER COLUMN "pledge" TYPE bigint USING pledge::bigint');
  }
}
