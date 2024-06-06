import { BlockDataEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class BlockDataTableMigration1682519108359 implements MigrationInterface {
  static entity = BlockDataEntity;

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "block_data" ("block_height" integer NOT NULL, "data" bytea NOT NULL, CONSTRAINT "PK_block_data_block_height" PRIMARY KEY ("block_height"))'
    );
    await queryRunner.query(
      'ALTER TABLE "block_data" ADD CONSTRAINT "FK_block_data_block_height" FOREIGN KEY ("block_height") REFERENCES "block"("height") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "block_data" DROP CONSTRAINT "FK_block_data_block_height"');
    await queryRunner.query('DROP TABLE "block_data"');
  }
}
