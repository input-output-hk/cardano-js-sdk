import { OutputEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class OutputTableMigration1682519108367 implements MigrationInterface {
  static entity = OutputEntity;

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "output" ("id" SERIAL NOT NULL, "address" character varying NOT NULL, "tx_id" character varying NOT NULL, "output_index" smallint NOT NULL, "coins" bigint NOT NULL, "consumed_at_slot" integer, "datum_hash" character(64), "datum" character varying, "script_reference" jsonb, "block_slot" integer NOT NULL, CONSTRAINT "PK_output_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query('CREATE INDEX "IDX_output_address" ON "output" ("address") ');
    await queryRunner.query('CREATE INDEX "IDX_output_tx_id" ON "output" ("tx_id") ');
    await queryRunner.query('CREATE INDEX "IDX_output_output_index" ON "output" ("output_index") ');
    await queryRunner.query(
      'ALTER TABLE "output" ADD CONSTRAINT "FK_output_block_slot" FOREIGN KEY ("block_slot") REFERENCES "block"("slot") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "output" DROP CONSTRAINT "FK_output_block_slot"');
    await queryRunner.query('DROP INDEX "public"."IDX_output_output_index"');
    await queryRunner.query('DROP INDEX "public"."IDX_output_tx_id"');
    await queryRunner.query('DROP INDEX "public"."IDX_output_address"');
    await queryRunner.query('DROP TABLE "output"');
  }
}
