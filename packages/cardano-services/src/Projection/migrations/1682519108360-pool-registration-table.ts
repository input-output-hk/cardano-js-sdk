import { PoolRegistrationEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class PoolRegistrationTableMigration1682519108360 implements MigrationInterface {
  static entity = PoolRegistrationEntity;

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "pool_registration" ("id" bigint NOT NULL, "reward_account" character varying NOT NULL, "pledge" bigint NOT NULL, "cost" bigint NOT NULL, "margin" jsonb NOT NULL, "margin_percent" real NOT NULL, "relays" jsonb NOT NULL, "owners" jsonb NOT NULL, "vrf" character(64) NOT NULL, "metadata_url" character varying, "metadata_hash" character(64), "stake_pool_id" character(56) NOT NULL, "block_slot" integer NOT NULL, CONSTRAINT "PK_pool_registration_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query(
      'ALTER TABLE "pool_registration" ADD CONSTRAINT "FK_pool_registration_block_slot" FOREIGN KEY ("block_slot") REFERENCES "block"("slot") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "pool_registration" DROP CONSTRAINT "FK_pool_registration_block_slot"');
    await queryRunner.query('DROP TABLE "pool_registration"');
  }
}
