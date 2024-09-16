import { MigrationInterface, QueryRunner } from 'typeorm';
import { NftMetadataEntity } from '@cardano-sdk/projection-typeorm';

export class NftMetadataIndexMigration1726479765002 implements MigrationInterface {
  static entity = NftMetadataEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'CREATE INDEX "IDX_nft_metadata_user_token_asset_id" ON "nft_metadata" ("user_token_asset_id") '
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP INDEX "public"."IDX_nft_metadata_user_token_asset_id"');
  }
}
