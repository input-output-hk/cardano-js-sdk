import { PoolRegistrationEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class FkPoolRegistrationMigration1682519108369 implements MigrationInterface {
  static entity = PoolRegistrationEntity;

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'ALTER TABLE "pool_registration" ADD CONSTRAINT "FK_pool_registration_stake_pool_id" FOREIGN KEY ("stake_pool_id") REFERENCES "stake_pool"("id") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
    await queryRunner.query(
      'ALTER TABLE "stake_pool" ADD CONSTRAINT "FK_stake_pool_last_registration_id" FOREIGN KEY ("last_registration_id") REFERENCES "pool_registration"("id") ON DELETE SET NULL ON UPDATE NO ACTION'
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "stake_pool" DROP CONSTRAINT "FK_stake_pool_last_registration_id"');
    await queryRunner.query('ALTER TABLE "pool_registration" DROP CONSTRAINT "FK_pool_registration_stake_pool_id"');
  }
}
