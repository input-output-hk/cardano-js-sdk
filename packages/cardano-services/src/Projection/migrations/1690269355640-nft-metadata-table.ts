import { NftMetadataEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class NftMetadataTableMigration1690269355640 implements MigrationInterface {
  static entity = NftMetadataEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('CREATE TYPE "public"."nft_metadata_type_enum" AS ENUM(\'CIP-0025\', \'CIP-0068\')');
    await queryRunner.query(
      'CREATE TABLE "nft_metadata" ("id" SERIAL NOT NULL, "name" character varying NOT NULL, "description" character varying, "image" character varying NOT NULL, "media_type" character varying, "files" jsonb, "type" "public"."nft_metadata_type_enum" NOT NULL, "other_properties" jsonb, "parent_asset_id" character varying NOT NULL, "user_token_asset_id" character varying, "created_at_slot" integer NOT NULL, CONSTRAINT "PK_nft_metadata_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query('ALTER TABLE "asset" ADD "nft_metadata_id" integer');
    await queryRunner.query(
      'ALTER TABLE "asset" ADD CONSTRAINT "UQ_asset_nft_metadata_id}" UNIQUE ("nft_metadata_id")'
    );
    await queryRunner.query(
      'ALTER TABLE "nft_metadata" ADD CONSTRAINT "FK_nft_metadata_parent_asset_id" FOREIGN KEY ("parent_asset_id") REFERENCES "asset"("id") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
    await queryRunner.query(
      'ALTER TABLE "nft_metadata" ADD CONSTRAINT "FK_nft_metadata_user_token_asset_id" FOREIGN KEY ("user_token_asset_id") REFERENCES "asset"("id") ON DELETE SET NULL ON UPDATE NO ACTION'
    );
    await queryRunner.query(
      'ALTER TABLE "nft_metadata" ADD CONSTRAINT "FK_nft_metadata_created_at_slot" FOREIGN KEY ("created_at_slot") REFERENCES "block"("slot") ON DELETE CASCADE ON UPDATE NO ACTION'
    );
    await queryRunner.query(
      'ALTER TABLE "asset" ADD CONSTRAINT "FK_asset_nft_metadata_id" FOREIGN KEY ("nft_metadata_id") REFERENCES "nft_metadata"("id") ON DELETE SET NULL ON UPDATE NO ACTION'
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "asset" DROP CONSTRAINT "FK_asset_nft_metadata_id"');
    await queryRunner.query('ALTER TABLE "nft_metadata" DROP CONSTRAINT "FK_nft_metadata_created_at_slot"');
    await queryRunner.query('ALTER TABLE "nft_metadata" DROP CONSTRAINT "FK_nft_metadata_user_token_asset_id"');
    await queryRunner.query('ALTER TABLE "nft_metadata" DROP CONSTRAINT "FK_nft_metadata_parent_asset_id"');
    await queryRunner.query('ALTER TABLE "asset" DROP CONSTRAINT "UQ_asset_nft_metadata_id}"');
    await queryRunner.query('ALTER TABLE "asset" DROP COLUMN "nft_metadata_id"');
    await queryRunner.query('DROP TABLE "nft_metadata"');
    await queryRunner.query('DROP TYPE "public"."nft_metadata_type_enum"');
  }
}
