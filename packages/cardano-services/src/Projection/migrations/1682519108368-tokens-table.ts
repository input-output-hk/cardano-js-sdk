import { TokensEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class TokensTableMigration1682519108368 implements MigrationInterface {
  static entity = TokensEntity;

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE TABLE "tokens" ("id" SERIAL NOT NULL, "quantity" bigint NOT NULL, "asset_id" character varying NOT NULL, "output_id" integer NOT NULL, CONSTRAINT "PK_tokens_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query(
      'ALTER TABLE "tokens" ADD CONSTRAINT "FK_tokens_asset_id" FOREIGN KEY ("asset_id") REFERENCES "asset"("id") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
    await queryRunner.query(
      'ALTER TABLE "tokens" ADD CONSTRAINT "FK_tokens_output_id" FOREIGN KEY ("output_id") REFERENCES "output"("id") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "tokens" DROP CONSTRAINT "FK_tokens_output_id"');
    await queryRunner.query('ALTER TABLE "tokens" DROP CONSTRAINT "FK_tokens_asset_id"');
    await queryRunner.query('DROP TABLE "tokens"');
  }
}
