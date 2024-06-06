import { HandleEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class HandleTableMigration1686138943349 implements MigrationInterface {
  static entity = HandleEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "handle" ("handle" character varying NOT NULL, "cardano_address" character varying, "policy_id" character varying NOT NULL, "has_datum" boolean NOT NULL, "asset_id" character varying, CONSTRAINT "REL_handle_asset_id" UNIQUE ("asset_id"), CONSTRAINT "PK_handle_handle" PRIMARY KEY ("handle"))'
    );
    await queryRunner.query(
      'ALTER TABLE "handle" ADD CONSTRAINT "FK_handle_asset_id" FOREIGN KEY ("asset_id") REFERENCES "asset"("id") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "handle" DROP CONSTRAINT "FK_handle_asset_id"');
    await queryRunner.query('DROP TABLE "handle"');
  }
}
