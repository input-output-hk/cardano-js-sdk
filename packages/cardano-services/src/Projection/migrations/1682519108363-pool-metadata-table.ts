import { PoolMetadataEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class PoolMetadataTableMigration1682519108363 implements MigrationInterface {
  static entity = PoolMetadataEntity;

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "pool_metadata" ("id" SERIAL NOT NULL, "ticker" character varying NOT NULL, "name" character varying NOT NULL, "description" character varying NOT NULL, "homepage" character varying NOT NULL, "hash" character varying NOT NULL, "ext" jsonb, "stake_pool_id" character(56), "pool_update_id" bigint NOT NULL, CONSTRAINT "REL_pool_metadata_pool_update_id" UNIQUE ("pool_update_id"), CONSTRAINT "PK_pool_metadata_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query('CREATE INDEX "IDX_pool_metadata_ticker" ON "pool_metadata" ("ticker") ');
    await queryRunner.query('CREATE INDEX "IDX_pool_metadata_name" ON "pool_metadata" ("name") ');
    await queryRunner.query(
      'ALTER TABLE "pool_metadata" ADD CONSTRAINT "FK_pool_metadata_stake_pool_id" FOREIGN KEY ("stake_pool_id") REFERENCES "stake_pool"("id") ON DELETE NO ACTION ON UPDATE NO ACTION'
    );
    await queryRunner.query(
      'ALTER TABLE "pool_metadata" ADD CONSTRAINT "FK_pool_metadata_pool_update_id" FOREIGN KEY ("pool_update_id") REFERENCES "pool_registration"("id") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "pool_metadata" DROP CONSTRAINT "FK_pool_metadata_pool_update_id"');
    await queryRunner.query('ALTER TABLE "pool_metadata" DROP CONSTRAINT "FK_pool_metadata_stake_pool_id"');
    await queryRunner.query('DROP INDEX "public"."IDX_pool_metadata_name"');
    await queryRunner.query('DROP INDEX "public"."IDX_pool_metadata_ticker"');
    await queryRunner.query('DROP TABLE "pool_metadata"');
  }
}
