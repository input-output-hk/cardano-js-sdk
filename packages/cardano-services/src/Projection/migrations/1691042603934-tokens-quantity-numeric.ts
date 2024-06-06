import { TokensEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class TokensQuantityNumericMigrations1691042603934 implements MigrationInterface {
  static entity = TokensEntity;

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "tokens" ALTER COLUMN "quantity" TYPE numeric(20,0) USING quantity::numeric');
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE "tokens" ALTER COLUMN "quantity" TYPE bigint USING quantity::bigint');
  }
}
