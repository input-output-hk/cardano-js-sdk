import { BlockEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class BlockTableMigration1682519108358 implements MigrationInterface {
  static entity = BlockEntity;

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "block" ("height" integer NOT NULL, "hash" character(64) NOT NULL, "slot" integer NOT NULL, CONSTRAINT "PK_block_slot" PRIMARY KEY ("slot"))'
    );
    await queryRunner.query('CREATE UNIQUE INDEX "IDX_block_height" ON "block" ("height") ');
    await queryRunner.query('CREATE UNIQUE INDEX "IDX_block_hash" ON "block" ("hash") ');
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP INDEX "public"."IDX_block_hash"');
    await queryRunner.query('DROP INDEX "public"."IDX_block_height"');
    await queryRunner.query('DROP TABLE "block"');
  }
}
