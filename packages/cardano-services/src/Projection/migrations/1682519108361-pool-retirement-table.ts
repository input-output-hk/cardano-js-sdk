import { PoolRetirementEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class PoolRetirementTableMigration1682519108361 implements MigrationInterface {
  static entity = PoolRetirementEntity;

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "pool_retirement" ("id" bigint NOT NULL, "retire_at_epoch" integer NOT NULL, "stake_pool_id" character(56) NOT NULL, "block_slot" integer NOT NULL, CONSTRAINT "PK_pool_retirement_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query(
      'ALTER TABLE "pool_retirement" ADD CONSTRAINT "FK_pool_retirement_block_slot" FOREIGN KEY ("block_slot") REFERENCES "block"("slot") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "pool_retirement" DROP CONSTRAINT "FK_pool_retirement_block_slot"');
    await queryRunner.query('DROP TABLE "pool_retirement"');
  }
}
