import { AssetEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AssetTableMigration1682519108365 implements MigrationInterface {
  static entity = AssetEntity;

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "asset" ("id" character varying NOT NULL, "supply" numeric NOT NULL, "first_mint_block_slot" integer NOT NULL, CONSTRAINT "PK_asset_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query(
      'ALTER TABLE "asset" ADD CONSTRAINT "FK_asset_first_mint_block_slot" FOREIGN KEY ("first_mint_block_slot") REFERENCES "block"("slot") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "asset" DROP CONSTRAINT "FK_asset_first_mint_block_slot"');
    await queryRunner.query('DROP TABLE "asset"');
  }
}
