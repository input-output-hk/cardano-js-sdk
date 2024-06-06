import { HandleMetadataEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class HandleMetadataTableMigrations1693490983715 implements MigrationInterface {
  static entity = HandleMetadataEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "handle_metadata" ("id" SERIAL NOT NULL, "handle" character varying NOT NULL, "og" boolean, "profile_pic_image" character varying, "background_image" character varying, "output_id" integer, "block_slot" integer NOT NULL, CONSTRAINT "PK_handle_metadata_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query('CREATE INDEX "IDX_handle_metadata_handle" ON "handle_metadata" ("handle") ');
    await queryRunner.query(
      'ALTER TABLE "handle_metadata" ADD CONSTRAINT "FK_handle_metadata_output_id" FOREIGN KEY ("output_id") REFERENCES "output"("id") ON DELETE NO ACTION ON UPDATE NO ACTION'
    );
    await queryRunner.query(
      'ALTER TABLE "handle_metadata" ADD CONSTRAINT "FK_handle_metadata_block_slot" FOREIGN KEY ("block_slot") REFERENCES "block"("slot") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "handle_metadata" DROP CONSTRAINT "FK_handle_metadata_block_slot"');
    await queryRunner.query('ALTER TABLE "handle_metadata" DROP CONSTRAINT "FK_handle_metadata_output_id"');
    await queryRunner.query('DROP INDEX "public"."IDX_handle_metadata_handle"');
    await queryRunner.query('DROP TABLE "handle_metadata"');
  }
}
