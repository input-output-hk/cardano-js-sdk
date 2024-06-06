import { StakePoolEntity } from '@cardano-sdk/projection-typeorm';
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class StakePoolTableMigration1682519108362 implements MigrationInterface {
  static entity = StakePoolEntity;

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      "CREATE TYPE \"public\".\"stake_pool_status_enum\" AS ENUM('activating', 'active', 'retired', 'retiring')"
    );
    await queryRunner.query(
      'CREATE TABLE "stake_pool" ("id" character(56) NOT NULL, "status" "public"."stake_pool_status_enum" NOT NULL, "last_registration_id" bigint, "last_retirement_id" bigint, CONSTRAINT "REL_stake_pool_last_registration_id" UNIQUE ("last_registration_id"), CONSTRAINT "REL_stake_pool_last_retirement_id" UNIQUE ("last_retirement_id"), CONSTRAINT "PK_stake_pool_id" PRIMARY KEY ("id"))'
    );
    await queryRunner.query('CREATE INDEX "IDX_stake_pool_status" ON "stake_pool" ("status") ');
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP INDEX "public"."IDX_stake_pool_status"');
    await queryRunner.query('DROP TABLE "stake_pool"');
    await queryRunner.query('DROP TYPE "public"."stake_pool_status_enum"');
  }
}
